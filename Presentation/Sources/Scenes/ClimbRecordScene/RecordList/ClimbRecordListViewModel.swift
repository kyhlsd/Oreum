//
//  ClimbRecordListViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import Foundation
import Combine
import Domain
import Core

final class ClimbRecordListViewModel: BaseViewModel {

    private let fetchUseCase: FetchClimbRecordUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private let fetchRecordImageUseCase: FetchRecordImageUseCase
    private let getRecordStatsUseCase: GetRecordStatsUseCase
    private var cancellables = Set<AnyCancellable>()

    private(set) var climbRecordList = [ClimbRecord]()
    private(set) var recordImageDatas: [String: [Data]] = [:]
    private let emptyText = "+ 버튼으로 이전 기록을 추가하거나,\n측정 탭에서 기록을 측정하여 추가할 수 있습니다."
    private var isOnlyBookmarked = false

    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    private lazy var emptyStateTextSubject = CurrentValueSubject<String, Never>(emptyText)
    private let recordUpdatedSubject = PassthroughSubject<String, Never>()
    private let statSubject = PassthroughSubject<(mountainCount: Int, climbCount: Int, totalHeight: Int), Never>()

    init(fetchUseCase: FetchClimbRecordUseCase, toggleBookmarkUseCase: ToggleBookmarkUseCase, fetchRecordImageUseCase: FetchRecordImageUseCase, getRecordStatsUseCase: GetRecordStatsUseCase) {
        self.fetchUseCase = fetchUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.fetchRecordImageUseCase = fetchRecordImageUseCase
        self.getRecordStatsUseCase = getRecordStatsUseCase
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let bookmarkButtonTapped: AnyPublisher<Void, Never>
        let cellBookmarkButtonTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let reloadData: AnyPublisher<Void, Never>
        let isOnlyBookmarked: AnyPublisher<Bool, Never>
        let bookmarkToggled: AnyPublisher<Int, Never>
        let emptyStateText: AnyPublisher<String, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
        let recordUpdated: AnyPublisher<String, Never>
        let stat: AnyPublisher<(mountainCount: Int, climbCount: Int, totalHeight: Int), Never>
    }
    
    func transform(input: Input) -> Output {
        let isOnlyBookmarkedSubject = CurrentValueSubject<Bool, Never>(isOnlyBookmarked)
        let searchTextSubject = CurrentValueSubject<String, Never>("")
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()

        // viewDidLoad 시 전체 데이터 불러와서 통계와 일지 모두 업데이트
        input.viewDidLoad
            .flatMap { [fetchUseCase] in
                fetchUseCase.execute(keyword: "", isOnlyBookmarked: false)
            }
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let records):
                    // 통계 계산
                    let stats = getRecordStatsUseCase.execute(records: records)
                    statSubject.send((mountainCount: stats.mountainCount, climbCount: stats.climbCount, totalHeight: stats.totalHeight))

                    // 일지 업데이트
                    climbRecordList = records
                    recordImageDatas = [:]
                    reloadDataSubject.send(())

                    if records.isEmpty {
                        emptyStateTextSubject.send(emptyText)
                    }

                case .failure(let error):
                    errorMessageSubject.send(("기록 불러오기 실패", error.localizedDescription))
                    climbRecordList = []
                    reloadDataSubject.send(())
                }
            }
            .store(in: &cancellables)
        
        // 검색 텍스트 업데이트
        input.searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { searchTextSubject.send($0) }
            .store(in: &cancellables)

        // 북마크만 표기 버튼
        input.bookmarkButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .scan(false) { last, _ in !last }
            .sink { [weak self] value in
                isOnlyBookmarkedSubject.send(value)
                self?.isOnlyBookmarked = value
            }
            .store(in: &cancellables)

        // 검색, 북마크 필터 변경 시 일지 다시 불러오기
        let searchText = searchTextSubject.eraseToAnyPublisher()
        let isOnlyBookmarked = isOnlyBookmarkedSubject.eraseToAnyPublisher()

        Publishers.CombineLatest(searchText, isOnlyBookmarked)
            .flatMap { [fetchUseCase] keyword, isOnlyBookmarked in
                fetchUseCase.execute(keyword: keyword, isOnlyBookmarked: isOnlyBookmarked)
                    .map { result -> (Result<[ClimbRecord], Error>, String) in
                        (result, keyword)
                    }
            }
            .sink { [weak self] (result, keyword) in
                guard let self else { return }

                switch result {
                case .success(let records):
                    climbRecordList = records
                    recordImageDatas = [:]
                    reloadDataSubject.send(())

                    if records.isEmpty {
                        if keyword.isEmpty {
                            emptyStateTextSubject.send(emptyText)
                        } else {
                            emptyStateTextSubject.send("검색 결과가 없습니다\n다른 키워드로 검색해보세요")
                        }
                    }

                case .failure(let error):
                    errorMessageSubject.send(("기록 불러오기 실패", error.localizedDescription))
                    climbRecordList = []
                    reloadDataSubject.send(())
                }
            }
            .store(in: &cancellables)

        // 새 기록 저장 시 일지 + 통계 갱신
        NotificationCenter.default
            .publisher(for: .climbRecordDidSave)
            .flatMap { [fetchUseCase] _ in
                fetchUseCase.execute(keyword: searchTextSubject.value, isOnlyBookmarked: isOnlyBookmarkedSubject.value)
            }
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let records):
                    climbRecordList = records
                    recordImageDatas = [:]
                    reloadDataSubject.send(())

                    if records.isEmpty {
                        if searchTextSubject.value.isEmpty {
                            emptyStateTextSubject.send(emptyText)
                        } else {
                            emptyStateTextSubject.send("검색 결과가 없습니다\n다른 키워드로 검색해보세요")
                        }
                    }

                    // 통계 갱신 (전체 데이터 기준)
                    self.refreshStats()

                case .failure(let error):
                    errorMessageSubject.send(("기록 불러오기 실패", error.localizedDescription))
                    climbRecordList = []
                    reloadDataSubject.send(())
                }
            }
            .store(in: &cancellables)
        
        // 셀 북마크 토글
        let bookmarkToggledSubject = PassthroughSubject<Int, Never>()

        input.cellBookmarkButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [toggleBookmarkUseCase] id in
                toggleBookmarkUseCase.execute(recordID: id)
                    .map { result -> (Result<Void, Error>, String) in
                        (result, id)
                    }
            }
            .sink { [weak self] (result, id) in
                guard let self else { return }
                switch result {
                case .success:
                    if let index = climbRecordList.firstIndex(where: { $0.id == id }) {
                        climbRecordList[index].isBookmarked.toggle()
                        bookmarkToggledSubject.send(index)
                    }
                case .failure(let error):
                    errorMessageSubject.send(("북마크 변경 실패", error.localizedDescription))
                    bookmarkToggledSubject.send(-1)
                }
            }
            .store(in: &cancellables)

        let bookmarkToggled = bookmarkToggledSubject.eraseToAnyPublisher()

        return Output(
            reloadData: reloadDataSubject.eraseToAnyPublisher(),
            isOnlyBookmarked: isOnlyBookmarked,
            bookmarkToggled: bookmarkToggled,
            emptyStateText: emptyStateTextSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            recordUpdated: recordUpdatedSubject.eraseToAnyPublisher(),
            stat: statSubject.eraseToAnyPublisher()
        )
    }

    func fetchImagesForRecord(recordId: String, completion: @escaping () -> Void) {
        // 이미 가져온 이미지가 있으면 바로 리턴
        if recordImageDatas[recordId] != nil {
            return
        }

        // 해당 레코드 찾기
        guard let record = climbRecordList.first(where: { $0.id == recordId }) else {
            return
        }

        // 이미지가 없으면 빈 배열 저장
        guard !record.images.isEmpty else {
            recordImageDatas[recordId] = []
            return
        }

        let imagePublishers = record.images.map { imageID in
            fetchRecordImageUseCase.execute(imageID: imageID)
                .compactMap { result -> Data? in
                    if case .success(let data) = result {
                        return data
                    }
                    return nil
                }
        }

        Publishers.MergeMany(imagePublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageDatas in
                self?.recordImageDatas[recordId] = imageDatas
                completion()
            }
            .store(in: &cancellables)
    }
}

// MARK: - ClimbRecordDetailViewModelDelegate
extension ClimbRecordListViewModel: ClimbRecordDetailViewModelDelegate {

    // 후기 업데이트
    func updateReview(id: String, rating: Int, comment: String) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList[index].score = rating
            climbRecordList[index].comment = comment
            recordUpdatedSubject.send(id)
        }
    }

    // 기록 삭제
    func deleteRecord(id: String) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList.remove(at: index)

            if climbRecordList.isEmpty {
                emptyStateTextSubject.send(emptyText)
            }

            reloadDataSubject.send(())
        }
    }

    // 이미지 업데이트
    func updateImages(id: String, images: [String]) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList[index].images = images

            // 이미지 캐시 무효화 (다음에 다시 가져오도록)
            recordImageDatas[id] = nil

            // 이미지 업데이트 알림
            recordUpdatedSubject.send(id)
        }
    }

    // 통계 갱신
    func refreshStats() {
        fetchUseCase.execute(keyword: "", isOnlyBookmarked: false)
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let records):
                    // 전체 데이터로 통계 재계산
                    let stats = self.getRecordStatsUseCase.execute(records: records)
                    self.statSubject.send((mountainCount: stats.mountainCount, climbCount: stats.climbCount, totalHeight: stats.totalHeight))
                case .failure:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
