import SwiftUI

struct FocusHomeView: View {
    // 选中的 Tab
    @State private var selectedTab: Int = 0
    
    // 选中的专注模式 (用于控制播放器显示)
    @State private var selectedMode: FocusMode?
    
    // 模拟数据
    let focusModes = [
        FocusMode(
            title: "专注模式",
            englishTitle: "Focus",
            desc1: "使用科学验证的声音",
            desc2: "消除环境的打扰",
            icon: "sun.max",
            colors: [Color(hex: "DAB07F"), Color(hex: "9F7B50")] // Gold/Brown gradient
        ),
        FocusMode(
            title: "宇宙频率",
            englishTitle: "Frequency",
            desc1: "激活副交感神经系统",
            desc2: "降低心率与皮质醇水平",
            icon: "globe",
            colors: [Color(hex: "B07BDE"), Color(hex: "7A4DA0")] // Purple gradient
        ),
        FocusMode(
            title: "彩色噪声",
            englishTitle: "Colored",
            desc1: "柔和掩蔽外界异响",
            desc2: "助力持续专注",
            icon: "dot.radiowaves.left.and.right",
            colors: [Color(hex: "848AD7"), Color(hex: "505590")] // Blue gradient
        ),
        FocusMode(
            title: "学习模式",
            englishTitle: "Study",
            desc1: "用轻松无序的声音频率",
            desc2: "保持冷静和专注",
            icon: "book",
            colors: [Color(hex: "666666"), Color(hex: "333333")] // Dark Grey gradient
        )
    ]
    
    let scenes = ["工作中", "写作业", "通勤", "读书", "思考"] // Add "思考" back based on CSS
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景色
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // 顶部标题区域 (移动到 ScrollView 内部)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("专注")
                                .font(.system(size: 20, weight: .regular)) // CSS size 20
                                .foregroundColor(.white)
                            
                            Text("提高工作和学习的效率")
                                .font(.system(size: 14)) // CSS size 14
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20) // Adjust padding
                        .padding(.horizontal, 20)
                        
                        // 1. 专注模式网格
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(focusModes) { mode in
                                FocusCardView(mode: mode) {
                                    // 点击卡片，设置选中的模式，触发全屏覆盖
                                    selectedMode = mode
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 2. 场景区域
                        VStack(alignment: .leading, spacing: 10) {
                            Text("场景")
                                .font(.system(size: 20, weight: .regular)) // Match header size style
                                .foregroundColor(.white)
                            
                            Text("选择不同场景定制专属频率")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "999999"))
                            
                            // 场景标签流式布局 (一行4个，宽度铺满)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                                ForEach(scenes, id: \.self) { scene in
                                    Text(scene)
                                        .font(.system(size: 13)) // CSS size 13
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40) // CSS height 40
                                        .background(Color(hex: "333333")) // CSS background
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 120) // 底部留白给 MiniPlayer 和 TabBar
                    }
                }
            }
            
            // 底部区域 (MiniPlayer + TabBar)
            VStack(spacing: 0) {
                // Mini Player
                Button(action: {
                    // 打开上次选中的模式，或者默认模式
                    if selectedMode == nil {
                         selectedMode = focusModes[1] // 默认宇宙频率
                    } else {
                         // 重新触发
                         let current = selectedMode
                         selectedMode = nil
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                             selectedMode = current
                         }
                    }
                }) {
                    HStack {
                        // 动态音频图标
                        HStack(spacing: 3) {
                            ForEach(0..<3) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.white)
                                    .frame(width: 2, height: [12, 18, 14][i]) // 模拟波形高度
                            }
                        }
                        .frame(width: 20, height: 20)
                        
                        Text("专注模式")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        Text("15:00")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 48) // CSS height 48
                    // 渐变背景 CSS: linear-gradient(0deg, #262626 0%, #3e3f40 100%)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "3E3F40"), Color(hex: "262626")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                // Tab Bar
                HStack {
                    TabBarItem(title: "专注", isSelected: selectedTab == 0)
                        .onTapGesture { selectedTab = 0 }
                    Spacer()
                    TabBarItem(title: "放松", isSelected: selectedTab == 1)
                        .onTapGesture { selectedTab = 1 }
                    Spacer()
                    TabBarItem(title: "睡眠", isSelected: selectedTab == 2)
                        .onTapGesture { selectedTab = 2 }
                    Spacer()
                    TabBarItem(title: "我的", isSelected: selectedTab == 3)
                        .onTapGesture { selectedTab = 3 }
                }
                .padding(.horizontal, 38) // CSS padding 38
                .frame(height: 58) // CSS height 58
                .background(Color(hex: "303133")) // CSS background
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .statusBar(hidden: false) // 首页显示状态栏
        .fullScreenCover(item: $selectedMode) { mode in
            // 打开播放器详情页
            FocusPlayerView(
                title: mode.title, // 动态传递标题
                category: mode.englishTitle, // 传递分类名称 (对应文件夹名)
                onModeSelect: {
                    print("Mode Select Tapped")
                },
                onBack: {
                    selectedMode = nil
                }
            )
        }
    }
}

// MARK: - Subviews

struct FocusCardView: View {
    let mode: FocusMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                // Icon
                Image(systemName: mode.icon)
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .padding(.top, 20)
                
                // English Title
                Text(mode.englishTitle)
                    .font(.custom("PingFang SC", size: 16)) // Fallback font
                    .foregroundColor(.white)
                
                // Chinese Title
                Text(mode.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                // Description
                VStack(spacing: 2) {
                    Text(mode.desc1)
                    Text(mode.desc2)
                }
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 5)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: mode.colors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(30) // CSS border-radius 30px
        }
    }
}

struct TabBarItem: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium)) // CSS size 16
            .foregroundColor(isSelected ? .white : Color(hex: "999999"))
    }
}

struct FocusMode: Identifiable {
    let id = UUID()
    let title: String
    let englishTitle: String
    let desc1: String
    let desc2: String
    let icon: String
    let colors: [Color]
}

// Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct FocusHomeView_Previews: PreviewProvider {
    static var previews: some View {
        FocusHomeView()
    }
}
