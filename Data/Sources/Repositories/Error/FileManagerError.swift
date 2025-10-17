//
//  FileManagerError.swift
//  Data
//
//  Created by 김영훈 on 10/17/25.
//

import Foundation

public enum FileManagerError {

    // 디렉토리를 찾을 수 없는 경우
    case documentDirectoryNotFound

    // 이미지 디렉토리 생성에 실패한 경우
    case failedToCreateImageDirectory

    // 이미지 디렉토리에 접근할 수 없는 경우
    case imageDirectoryNotAccessible

    // 이미지 데이터를 파일로 저장하는데 실패한 경우
    case failedToSaveImage

    // 이미지 파일을 삭제하는데 실패한 경우
    case failedToDeleteImage

    // 이미지 파일을 읽는데 실패한 경우
    case failedToLoadImage

    // 이미지 파일이 존재하지 않는 경우
    case imageFileNotFound

    // Repository 인스턴스가 해제된 경우
    case repositoryDeallocated

    // 알 수 없는 오류
    case unknown
    
}

extension FileManagerError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .documentDirectoryNotFound:
            return "문서 디렉토리를 찾을 수 없습니다."
            
        case .failedToCreateImageDirectory:
            return "이미지 디렉토리를 생성할 수 없습니다."
            
        case .imageDirectoryNotAccessible:
            return "이미지 디렉토리에 접근할 수 없습니다."
            
        case .failedToSaveImage:
            return "이미지를 저장할 수 없습니다."
            
        case .failedToDeleteImage:
            return "이미지를 삭제할 수 없습니다."
            
        case .failedToLoadImage:
            return "이미지를 불러올 수 없습니다."
            
        case .imageFileNotFound:
            return "이미지 파일을 찾을 수 없습니다."
            
        case .repositoryDeallocated:
            return "Repository가 이미 해제되었습니다."
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
}
