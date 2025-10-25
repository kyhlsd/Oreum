//
//  NetworkCache.swift
//  Data
//
//  Created by Claude on 10/25/25.
//

import Foundation

actor NetworkCache {

    static let shared = NetworkCache()

    // L1: 메모리 캐시 (NSCache)
    nonisolated(unsafe) private let memoryCache = NSCache<NSString, CachedData>()

    // L2: 디스크 캐시 경로
    private let diskCacheDirectory: URL

    // 캐시 만료 시간 (기본 1시간)
    private let cacheExpiration: TimeInterval

    // 디스크 캐시 최대 용량 (기본 100MB)
    private let diskCacheLimit: Int

    private init(cacheExpiration: TimeInterval = 3600, diskCacheLimit: Int = 100 * 1024 * 1024) {
        self.cacheExpiration = cacheExpiration
        self.diskCacheLimit = diskCacheLimit

        // 디스크 캐시 디렉토리 설정
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.diskCacheDirectory = cacheDirectory.appendingPathComponent("NetworkCache")

        // 디렉토리 생성
        createCacheDirectoryIfNeeded()

        // 메모리 캐시 설정
        memoryCache.countLimit = 100 // 최대 100개 항목
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 최대 50MB
    }

    // MARK: - Public Methods

    // 캐시에서 데이터 조회 (NSCache → FileManager → nil)
    func getData(for key: String) async -> Data? {
        let cacheKey = NSString(string: key)

        // L1: 메모리 캐시 확인
        if let cachedData = memoryCache.object(forKey: cacheKey) {
            // 만료 확인
            if !cachedData.isExpired {
                return cachedData.data
            } else {
                // 만료된 데이터 제거
                memoryCache.removeObject(forKey: cacheKey)
            }
        }

        // L2: 디스크 캐시 확인
        if let diskData = getDiskCache(for: key) {
            // 메모리 캐시에도 저장
            let cachedData = CachedData(data: diskData, expiration: cacheExpiration)
            memoryCache.setObject(cachedData, forKey: cacheKey)
            return diskData
        }

        return nil
    }

    // 캐시에 데이터 저장 (NSCache + FileManager)
    func setData(_ data: Data, for key: String) async {
        let cacheKey = NSString(string: key)
        let cachedData = CachedData(data: data, expiration: cacheExpiration)

        // L1: 메모리 캐시 저장
        memoryCache.setObject(cachedData, forKey: cacheKey, cost: data.count)

        // L2: 디스크 캐시 저장
        saveDiskCache(data, for: key)
    }

    // 특정 키의 캐시 삭제
    func removeData(for key: String) async {
        let cacheKey = NSString(string: key)

        // 메모리 캐시 삭제
        memoryCache.removeObject(forKey: cacheKey)

        // 디스크 캐시 삭제
        removeDiskCache(for: key)
    }

    // 모든 캐시 삭제
    func clearAll() async {
        // 메모리 캐시 삭제
        memoryCache.removeAllObjects()

        // 디스크 캐시 삭제
        clearDiskCache()
    }

    // 만료된 캐시 정리
    func cleanExpiredCache() async {
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: diskCacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        let now = Date()

        for fileURL in fileURLs {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                  let modificationDate = attributes[.modificationDate] as? Date else {
                continue
            }

            // 만료 확인
            if now.timeIntervalSince(modificationDate) > cacheExpiration {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    // MARK: - Private Methods

    nonisolated private func createCacheDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: diskCacheDirectory.path) {
            try? FileManager.default.createDirectory(
                at: diskCacheDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    private func getDiskCache(for key: String) -> Data? {
        let fileURL = diskCacheURL(for: key)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        // 파일 수정 날짜 확인 (만료 체크)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return nil
        }

        let now = Date()
        if now.timeIntervalSince(modificationDate) > cacheExpiration {
            // 만료된 파일 삭제
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }

        return try? Data(contentsOf: fileURL)
    }

    private func saveDiskCache(_ data: Data, for key: String) {
        // 용량 체크 및 정리
        ensureDiskCacheLimit()

        let fileURL = diskCacheURL(for: key)
        try? data.write(to: fileURL, options: .atomic)
    }

    private func removeDiskCache(for key: String) {
        let fileURL = diskCacheURL(for: key)
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func clearDiskCache() {
        try? FileManager.default.removeItem(at: diskCacheDirectory)
        createCacheDirectoryIfNeeded()
    }

    private func diskCacheURL(for key: String) -> URL {
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return diskCacheDirectory.appendingPathComponent(fileName)
    }

    // 디스크 캐시 용량 확인 및 초과 시 오래된 파일 삭제 (LRU)
    private func ensureDiskCacheLimit() {
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: diskCacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentAccessDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        // 전체 디스크 캐시 크기 계산
        var totalSize = 0
        var filesWithInfo: [(url: URL, size: Int, accessDate: Date)] = []

        for fileURL in fileURLs {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .contentAccessDateKey]),
                  let fileSize = resourceValues.fileSize,
                  let accessDate = resourceValues.contentAccessDate else {
                continue
            }

            totalSize += fileSize
            filesWithInfo.append((url: fileURL, size: fileSize, accessDate: accessDate))
        }

        // 용량 초과 시 오래된 파일부터 삭제
        if totalSize > diskCacheLimit {
            // 접근 날짜 기준 오름차순 정렬 (오래된 것부터)
            filesWithInfo.sort { $0.accessDate < $1.accessDate }

            var currentSize = totalSize
            for fileInfo in filesWithInfo {
                if currentSize <= diskCacheLimit {
                    break
                }

                try? FileManager.default.removeItem(at: fileInfo.url)
                currentSize -= fileInfo.size
            }
        }
    }
}

// MARK: - CachedData

private class CachedData {
    let data: Data
    let timestamp: Date
    let expiration: TimeInterval

    init(data: Data, expiration: TimeInterval) {
        self.data = data
        self.timestamp = Date()
        self.expiration = expiration
    }

    var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > expiration
    }
}
