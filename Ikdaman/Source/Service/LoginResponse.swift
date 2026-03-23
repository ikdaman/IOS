import Foundation

// MARK: - Login Response Models

struct LoginResponse: Codable {
    let isRegistered: Bool?
    let needsSignup: Bool?
    let message: String?
    
    // 로그인 성공 시 토큰은 헤더로 오므로 body에는 없을 수 있음
    
    /// 회원가입이 필요한지 여부
    var requiresSignup: Bool {
        // isRegistered가 false이거나
        if let isRegistered = isRegistered {
            return !isRegistered
        }
        // needsSignup이 true이면 회원가입 필요
        if let needsSignup = needsSignup {
            return needsSignup
        }
        // 두 필드 모두 없으면 회원가입 필요로 간주
        return true
    }
}

// 빈 응답용
struct EmptyResponse: Codable {}

// 닉네임 체크 응답
struct NicknameCheckResponse: Codable {
    let isAvailable: Bool
    let message: String?
}
