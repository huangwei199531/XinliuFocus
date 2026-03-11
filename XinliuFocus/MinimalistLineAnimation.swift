import SwiftUI

struct MinimalistLineAnimation: View {
    // MARK: - 可调节选项
    var lineWidth: CGFloat = 2.0        // 线条粗细
    var lineCount: Int = 12             // 线条数量 (会生成左右对称的对数)
    var height: CGFloat = 500           // 动效高度
    var amplitudeMultiplier: CGFloat = 1.0 // 振幅强度 (控制波浪宽窄)
    var frequencyMultiplier: Double = 1.0  // 频率强度 (控制波浪密集度)
    var speedMultiplier: Double = 1.0      // 速度强度 (控制流动快慢)
    
    var body: some View {
        ZStack {
            // 背景设为透明，以便在外部容器中叠加
            Color.clear
            
            // 生成对称的线条组
            ForEach(0..<lineCount, id: \.self) { i in
                SymmetricVerticalWave(
                    index: i,
                    baseLineWidth: lineWidth,
                    amplitudeMultiplier: amplitudeMultiplier,
                    frequencyMultiplier: frequencyMultiplier,
                    speedMultiplier: speedMultiplier
                )
            }
        }
        // 强制设定高度，同时保证宽度充满父视图
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

struct SymmetricVerticalWave: View {
    let index: Int
    let baseLineWidth: CGFloat
    let amplitudeMultiplier: CGFloat
    let frequencyMultiplier: Double
    let speedMultiplier: Double
    
    @State private var phase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            
            // 1. 分组逻辑 (3组)
            let group = index % 3
            
            // 2. 速率控制
            // 基础周期 / 速度系数 (系数越大，周期越短，速度越快)
            let baseDuration: Double = {
                switch group {
                case 0: return 6.0 + Double(index) * 0.2
                case 1: return 4.0 + Double(index) * 0.1
                case 2: return 2.0 + Double(index) * 0.1
                default: return 5.0
                }
            }()
            let speedDuration = baseDuration / max(speedMultiplier, 0.1)
            
            // 3. 样式参数
            let opacity: Double = [0.3, 0.5, 0.9][group]
            
            // 振幅计算：基础振幅 * 系数
            let baseAmplitude = [10.0, 20.0, 30.0][group] + CGFloat(index * 2)
            let amplitude = baseAmplitude * amplitudeMultiplier
            
            // 频率计算：基础频率 * 系数
            let baseFrequency = [1.0, 1.5, 2.0][group]
            let frequency = baseFrequency * frequencyMultiplier
            
            // 4. 位置偏移 (从中心向外扩散)
            // 也会受到振幅系数的一定影响，避免波浪变大时重叠过多
            let xOffset = (CGFloat(index) * 12.0 + 20.0) * (amplitudeMultiplier > 1 ? sqrt(amplitudeMultiplier) : 1)
            
            // 5. 线条粗细
            let currentLineWidth = baseLineWidth * [0.8, 1.0, 1.2][group]
            
            ZStack {
                // 左侧线条 (镜像)
                VerticalWaveShape(
                    phase: phase,
                    amplitude: amplitude,
                    frequency: frequency,
                    direction: -1 // 反向
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0), .white.opacity(opacity), .white.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: currentLineWidth, lineCap: .round)
                )
                // 增加宽度冗余，防止大振幅时被裁剪
                .frame(width: max(width, amplitude * 4 + currentLineWidth), height: height)
                .position(x: centerX - xOffset, y: height / 2)
                
                // 右侧线条
                VerticalWaveShape(
                    phase: phase,
                    amplitude: amplitude,
                    frequency: frequency,
                    direction: 1 // 正向
                )
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0), .white.opacity(opacity), .white.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: currentLineWidth, lineCap: .round)
                )
                .frame(width: max(width, amplitude * 4 + currentLineWidth), height: height)
                .position(x: centerX + xOffset, y: height / 2)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: speedDuration).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
    }
}

struct VerticalWaveShape: Shape {
    var phase: Double
    var amplitude: CGFloat
    var frequency: Double
    var direction: CGFloat
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let height = rect.height
        let midWidth = rect.width / 2
        
        path.move(to: CGPoint(x: midWidth, y: 0))
        
        for y in stride(from: 0, to: height, by: 2) {
            let relativeY = y / height
            // 向下流动
            let sine = sin(relativeY * frequency * .pi * 2 - phase)
            let x = midWidth + CGFloat(sine) * amplitude * direction
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

struct MinimalistLineAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            // 预览：高度500，稍微增加一点振幅和频率
            MinimalistLineAnimation(
                lineWidth: 2,
                lineCount: 12,
                height: 500,
                amplitudeMultiplier: 1.2,
                frequencyMultiplier: 1.0,
                speedMultiplier: 1.0
            )
        }
    }
}
