import SwiftUI

// MARK: - Font Extension for Custom Fonts

extension Font {
    
    // MARK: - Font Names
    /// 여기에 Resource 폴더에 있는 실제 폰트 파일명을 입력하세요
    private enum CustomFontName: String {
        // 예시:
        case pretendardRegular = "Pretendard-Regular"
        case pretendardBold = "Pretendard-Bold"
        case pretendardSemiBold = "Pretendard-SemiBold"
        case pretendardMedium = "Pretendard-Medium"
        case pretendardLight = "Pretendard-Light"
        case dungenmo = "DungGeunMo"
        case wantedSansRegular = "WantedSans-Regular"
        case wantedSansSemiBold = "WantedSans-SemiBold"
    }
    
    // MARK: - Custom Font Methods
    
    /// Regular 폰트
    static func customRegular(size: CGFloat) -> Font {
        return .custom(CustomFontName.pretendardRegular.rawValue, size: size)
    }
    
    /// Medium 폰트
    static func customMedium(size: CGFloat) -> Font {
        return .custom(CustomFontName.pretendardMedium.rawValue, size: size)
    }
    
    /// SemiBold 폰트
    static func customSemiBold(size: CGFloat) -> Font {
        return .custom(CustomFontName.pretendardSemiBold.rawValue, size: size)
    }
    
    /// Bold 폰트
    static func customBold(size: CGFloat) -> Font {
        return .custom(CustomFontName.pretendardBold.rawValue, size: size)
    }
    
    /// Light 폰트
    static func customLight(size: CGFloat) -> Font {
        return .custom(CustomFontName.pretendardLight.rawValue, size: size)
    }
    
    /// 둥근모 폰트
    static func customDungGeunMo(size: CGFloat) -> Font {
        return .custom(CustomFontName.dungenmo.rawValue, size: size)
    }
    
    /// WantedSans-Regular 폰트
    static func customSansRegular(size: CGFloat) -> Font {
        return .custom(CustomFontName.wantedSansRegular.rawValue, size: size)
    }
    
    /// WantedSans-SemiBold 폰트
    static func customSansSemiBold(size: CGFloat) -> Font {
        return .custom(CustomFontName.wantedSansSemiBold.rawValue, size: size)
    }
}

