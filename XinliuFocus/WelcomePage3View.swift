import SwiftUI

struct WelcomePage3View: View {
    var showContentOnly: Bool = false
    
    var body: some View {
        ZStack {
            // 背景：深蓝色垂直渐变 (作为后备或底层)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.15, blue: 0.15), // 深青色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // 背景图片
            Image("WelcomeBackground3")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // 主要内容区域
                VStack(spacing: 0) {
                    // 主标题
                    VStack(spacing: 5) {
                        Text("用声音和节奏")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Text("保持最佳的专注")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .tracking(1)
                    }
                    
                    // 副标题
                    VStack(spacing: 4) {
                        Text("规律节奏辅助提升专注度")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.65, green: 0.69, blue: 0.72)) // #A7B0B7
                        
                        Text("提升专注力和专注时间")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.65, green: 0.69, blue: 0.72)) // #A7B0B7
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                
                .padding(.bottom, 100)
                
//                Spacer()
                
                // 步骤指示器 (第3步高亮)
                HStack(spacing: 8) {
                    // 第1步 (灰色)
                    Capsule()
                        .fill(Color(red: 0.4, green: 0.4, blue: 0.4)) // #666666
                        .frame(width: 30, height: 4)
                    
                    // 第2步 (灰色)
                    Capsule()
                        .fill(Color(red: 0.4, green: 0.4, blue: 0.4)) // #666666
                        .frame(width: 30, height: 4)
                        
                    // 第3步 (高亮/白色)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 30, height: 4)
                        
                    // 第4步 (灰色)
                    Capsule()
                        .fill(Color(red: 0.4, green: 0.4, blue: 0.4)) // #666666
                        .frame(width: 30, height: 4)
                }
                .padding(.bottom, 150)
                
                // 按钮占位
                 Color.clear
                    .frame(height: 52)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct WelcomePage3View_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage3View()
    }
}
