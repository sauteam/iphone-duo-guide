//
//  DuoDualPaneBaseController.swift
//

import UIKit
import SnapKit

/// 通用自适应双窗格基类控制器
open class DuoDualPaneBaseController: UIViewController {

    /// 左窗格引导区域 (0 ~ 459.5pt)
    public let leftPaneGuide = UILayoutGuide()
    /// 右窗格引导区域 (491.5 ~ 867pt)
    public let rightPaneGuide = UILayoutGuide()

    /// 当前是否处于双窗格状态
    public private(set) var isCurrentlyDualPane: Bool = false

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPaneGuides()
        setupSubviews()
        updateLayoutConstraints(isDualPane: isDualPaneLandscape())
    }

    private func setupPaneGuides() {
        view.addLayoutGuide(leftPaneGuide)
        view.addLayoutGuide(rightPaneGuide)
    }

    /// 子类重写：添加子视图并建立初始通用关系
    open func setupSubviews() {
        // 由子类实现
    }

    /// 子类重写：在双窗格与标准单列布局之间切换约束
    open func updateLayoutConstraints(isDualPane: Bool) {
        self.isCurrentlyDualPane = isDualPane

        if isDualPane {
            // MARK: - Duo 展开横屏左右双窗格
            leftPaneGuide.snp.remakeConstraints { make in
                make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
                make.trailing.equalTo(view.snp.centerX).offset(-DuoDisplay.hingeBufferOffset)
                make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            }

            rightPaneGuide.snp.remakeConstraints { make in
                make.leading.equalTo(view.snp.centerX).offset(DuoDisplay.hingeBufferOffset)
                make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
                make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        } else {
            // MARK: - 标准单屏全宽流式布局
            leftPaneGuide.snp.remakeConstraints { make in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
            rightPaneGuide.snp.remakeConstraints { make in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }

    // MARK: - 屏幕尺寸与旋转自适应监听
    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        let isDual = isDualPaneLandscape(for: size)
        
        coordinator.animate { [weak self] _ in
            self?.updateLayoutConstraints(isDualPane: isDual)
            self?.view.layoutIfNeeded()
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shouldBeDual = isDualPaneLandscape()
        if isCurrentlyDualPane != shouldBeDual {
            updateLayoutConstraints(isDualPane: shouldBeDual)
        }
    }
}


public extension UIViewController {
    
    /// 判断当前控制器视图是否处于双窗格展开横屏
    func isDualPaneLandscape(for targetSize: CGSize? = nil) -> Bool {
        return DuoDisplay.isDualPaneLandscape(
            size: targetSize ?? view.bounds.size,
            traitCollection: traitCollection
        )
    }
    
    /// 获取真实右侧安全区边距 (自动兼容 84pt 垂直导航栏)
    var effectiveTrailingMargin: CGFloat {
        let safeTrailing = view.safeAreaInsets.right
        return max(safeTrailing, 16.0)
    }
}
