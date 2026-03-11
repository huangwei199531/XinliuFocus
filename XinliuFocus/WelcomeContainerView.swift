import SwiftUI

// 欢迎页容器视图：负责管理和切换所有的欢迎页面
struct WelcomeContainerView: View {
    // 使用 @State 状态变量来跟踪当前显示的页面索引
    // 0: 第一页, 1: 第二页, 2: 第三页
    @State private var currentPage = 0
    
    // 是否已完成引导
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding: Bool = false
    
    var body: some View {
        if hasFinishedOnboarding {
            // 如果已完成引导，直接显示主页
            FocusHomeView()
        } else {
            // 否则显示欢迎页容器
            ZStack {
                // 背景层：根据 currentPage 动态显示不同的子页面
                Group {
                    if currentPage == 0 {
                        // 显示第一页，并传入 showContentOnly 参数
                        WelcomePage1View(showContentOnly: true)
                            .transition(.opacity) // 页面切换时的透明度过渡效果
                    } else if currentPage == 1 {
                        // 显示第二页
                        WelcomePage2View(showContentOnly: true)
                            .transition(.opacity)
                    } else if currentPage == 2 {
                        // 显示第三页
                        WelcomePage3View(showContentOnly: true)
                            .transition(.opacity)
                    } else {
                        // 显示第四页
                        WelcomePage4View(showContentOnly: true)
                            .transition(.opacity)
                    }
                }
                // 当 currentPage 发生变化时，应用 easeInOut 动画效果
                .animation(.easeInOut, value: currentPage)
                
                // 手势处理层：覆盖一个透明视图来捕获滑动手势
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(Rectangle()) // 确保透明区域也能响应点击/触摸
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    // 检测水平滑动距离
                                    if value.translation.width < -50 {
                                        // 向左滑动 (位移 < -50) -> 切换到下一页
                                        if currentPage < 3 {
                                            withAnimation {
                                                currentPage += 1
                                            }
                                        }
                                    } else if value.translation.width > 50 {
                                        // 向右滑动 (位移 > 50) -> 切换到上一页
                                        if currentPage > 0 {
                                            withAnimation {
                                                currentPage -= 1
                                            }
                                        }
                                    }
                                }
                        )
                }
                
                // 按钮层 (悬浮在最上层)
                VStack {
                    Spacer() // 占位符，将按钮推到底部
                    
                    // 统一的"继续"按钮
                    Button(action: {
                        if currentPage < 3 {
                            // 如果不是最后一页，点击切换到下一页
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // 如果是最后一页，标记为完成，切换到主页
                            withAnimation {
                                hasFinishedOnboarding = true
                            }
                        }
                    }) {
                        Text(currentPage == 3 ? "进入心流 FM" : "继续")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 300, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2)) // 深灰背景
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 1) // 描边
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2) // 按钮阴影
                    }
                    .padding(.bottom, 40) // 底部留白
                }
            }
        }
    }
}

struct WelcomeContainerView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeContainerView()
    }
}
