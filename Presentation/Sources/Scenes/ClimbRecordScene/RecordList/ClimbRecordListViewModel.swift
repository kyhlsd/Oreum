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
    private var cancellables = Set<AnyCancellable>()

    private(set) var climbRecordList = [ClimbRecord]()
    private(set) var recordImageDatas: [String: [Data]] = [:]
    private let baseGuideText = "산을 눌러 자세한 정보를 확인하세요."
    private let emptyText = "+ 버튼으로 이전 기록을 추가하거나,\n측정 탭에서 기록을 측정하여 추가할 수 있습니다"
    private var isOnlyBookmarked = false
    
    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    private lazy var guideTextSubject = CurrentValueSubject<String, Never>(baseGuideText)
    private lazy var emptyStateTextSubject = CurrentValueSubject<String, Never>(emptyText)
    private let imageUpdatedSubject = PassthroughSubject<String, Never>()

    init(fetchUseCase: FetchClimbRecordUseCase, toggleBookmarkUseCase: ToggleBookmarkUseCase, fetchRecordImageUseCase: FetchRecordImageUseCase) {
        self.fetchUseCase = fetchUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.fetchRecordImageUseCase = fetchRecordImageUseCase
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let bookmarkButtonTapped: AnyPublisher<Void, Never>
        let cellBookmarkButtonTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let reloadData: AnyPublisher<Void, Never>
        let guideText: AnyPublisher<String, Never>
        let isOnlyBookmarked: AnyPublisher<Bool, Never>
        let bookmarkToggled: AnyPublisher<Int, Never>
        let emptyStateText: AnyPublisher<String, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
        let imageUpdated: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        let isOnlyBookmarkedSubject = CurrentValueSubject<Bool, Never>(isOnlyBookmarked)
        let searchTextSubject = CurrentValueSubject<String, Never>("")
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()

        // 최초 모든 기록 불러오기
        input.viewDidLoad
            .map { "" }
            .merge(with: input.searchText)
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

        // 검색 시
        let searchText = searchTextSubject.eraseToAnyPublisher()
        // 북마크만 표기 상태 변경
        let isOnlyBookmarked = isOnlyBookmarkedSubject.eraseToAnyPublisher()
        // 새로운 기록이 저장되었을 때
        let climbRecordDidSave = NotificationCenter.default
            .publisher(for: .climbRecordDidSave)
            .map { _ in (searchTextSubject.value, isOnlyBookmarkedSubject.value) }
            .eraseToAnyPublisher()
        // 위 세 가지 경우에 기록 불러오기
        Publishers.Merge(
            Publishers.CombineLatest(searchText, isOnlyBookmarked),
            climbRecordDidSave
        )
            .flatMap { [fetchUseCase] keyword, isOnlyBookmarked in
                fetchUseCase.execute(keyword: keyword, isOnlyBookmarked: isOnlyBookmarked)
                    .map { result -> (Result<[ClimbRecord], Error>, String, Bool) in
                        (result, keyword, isOnlyBookmarked)
                    }
            }
            .sink { [weak self] (result, keyword, isOnlyBookmarked) in
                guard let self else { return }

                let list: [ClimbRecord]
                switch result {
                case .success(let records):
                    list = records
                case .failure(let error):
                    errorMessageSubject.send(("기록 불러오기 실패", error.localizedDescription))
                    list = []
                }

                climbRecordList = list

                // 이미지 캐시 초기화 (새로운 검색이므로)
                recordImageDatas = [:]

                // 기록 컬렉션 뷰 갱신
                reloadDataSubject.send(())

                // 북마크만, 개수 레이블 텍스트 업데이트
                if isOnlyBookmarked {
                    guideTextSubject.send("북마크한 산들 (\(list.count)개)")
                } else {
                    guideTextSubject.send("\(baseGuideText) (\(list.count)개)")
                }

                // 검색 결고 유무에 따른 업데이트
                if list.isEmpty {
                    if keyword.isEmpty {
                        emptyStateTextSubject.send(emptyText)
                    } else {
                        emptyStateTextSubject.send("검색 결과가 없습니다\n다른 키워드로 검색해보세요")
                    }
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
            guideText: guideTextSubject.eraseToAnyPublisher(),
            isOnlyBookmarked: isOnlyBookmarked,
            bookmarkToggled: bookmarkToggled,
            emptyStateText: emptyStateTextSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            imageUpdated: imageUpdatedSubject.eraseToAnyPublisher()
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
        }
    }

    // 기록 삭제
    func deleteRecord(id: String) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList.remove(at: index)

            if isOnlyBookmarked {
                guideTextSubject.send("북마크한 산들 (\(climbRecordList.count)개)")
            } else {
                guideTextSubject.send("\(baseGuideText) (\(climbRecordList.count)개)")
            }

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
            imageUpdatedSubject.send(id)
        }
    }
}
