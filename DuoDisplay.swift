//
//  DuoDisplay.swift
//

import UIKit

/// 通用 iPhone Duo 与双屏展开状态判定引擎
public enum DuoDisplay {
    
    /// 中央物理铰链折痕的 X 轴物理坐标点 (内屏横屏 951pt 时为 475.5pt)
    public static let hingeCenterThreshold: CGFloat = 475.5
    
    /// 官方推荐折痕单边安全避让间距 (中缝总宽度预留 32pt)
    public static let hingeBufferOffset: CGFloat = 16.0
    
    /// 右侧垂直导航栏固定宽度
    public static let verticalBarWidth: CGFloat = 84.0
    
    /// 浮动抽屉推荐黄金宽度
    public static let floatingSheetWidth: CGFloat = 420.0

    /// 是否处于 Duo 展开横屏（或大屏双窗格）有效状态
    public static func isDualPaneLandscape(
        size: CGSize? = nil,
        traitCollection: UITraitCollection? = nil
    ) -> Bool {
        let currentSize = size ?? (activeWindow?.bounds.size ?? UIScreen.main.bounds.size)
        let isLandscape = currentSize.width > currentSize.height
        
        let tc = traitCollection ?? activeWindow?.traitCollection
        let isRegular = tc?.horizontalSizeClass == .regular
        
        // 阈值说明:
        // 标准 iPhone (如 16 Pro Max 横屏为 440pt 宽) 不应触发双窗格
        // Duo 外屏横屏为 678pt (Compact)，展开内屏横屏为 951pt (Regular)
        let isWide = currentSize.width >= 700 || (currentSize.width >= 600 && isRegular)
        return isLandscape && isWide
    }

    /// 获取当前活跃的 KeyWindow
    public static var activeWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
