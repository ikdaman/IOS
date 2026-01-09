//
//  NetworkError.swift
//  Ikdaman
//
//  Created by Soo on 1/7/26.
//

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case encodingError
    case httpError(statusCode: Int, message: String?)
    case unauthorized
    case serverError(String)
    case networkFailure(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .noData:
            return "데이터가 없습니다."
        case .decodingError(let message):
            return "디코딩 실패: \(message)"
        case .encodingError:
            return "인코딩 실패"
        case .httpError(let statusCode, let message):
            return "HTTP 오류 (\(statusCode)): \(message ?? "알 수 없는 오류")"
        case .unauthorized:
            return "인증이 필요합니다."
        case .serverError(let message):
            return "서버 오류: \(message)"
        case .networkFailure(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
