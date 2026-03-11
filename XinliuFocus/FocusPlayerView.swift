import SwiftUI
import Combine
import AVFoundation

// 音频播放管理器
class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    @Published var currentTrackName: String = ""
    private var audioPlayer: AVAudioPlayer?
    private var playlist: [URL] = []
    private var currentIndex: Int = 0
    var category: String = "" // 当前播放的分类 (文件夹名称)
    
    override init() {
        super.init()
        // init 时不加载，改为由 View 在 onAppear 时触发 loadPlaylist(category:)
    }
    
    // 加载播放列表
    func loadPlaylist(category: String) {
        self.category = category
        let supportedExtensions = ["mp3", "m4a", "wav", "aac"]
        var urls: [URL] = []
        
        print("📂 正在加载分类音乐: \(category)")
        
        // 尝试从对应分类的子文件夹中加载
        for ext in supportedExtensions {
            // 1. 尝试查找名为 category 的子目录
            if let foundUrls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: category) {
                urls.append(contentsOf: foundUrls)
            }
            
            // 2. 兼容性：如果子目录没找到，尝试在根目录查找文件名包含 category 的文件 (例如 "Focus_01.mp3")
            // 注意：如果用户没有使用 "Folder References" (蓝色文件夹)，文件会被拍平在根目录
            if let rootUrls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                let filtered = rootUrls.filter { url in
                    // 排除已经添加的
                    !urls.contains(url) && 
                    url.lastPathComponent.lowercased().contains(category.lowercased())
                }
                urls.append(contentsOf: filtered)
            }
        }
        
        // 去重
        let uniqueUrls = Array(Set(urls))
        
        // 随机打乱顺序
        self.playlist = uniqueUrls.shuffled()
        
        if playlist.isEmpty {
            print("⚠️ 分类 [\(category)] 下未找到音乐文件")
            print("💡 建议：\n1. 将音乐文件夹拖入 Xcode 时选择 'Create folder references' (蓝色文件夹)\n2. 文件夹名称需匹配: \(category)\n3. 或者将文件命名为 '\(category)_xx.mp3'")
        } else {
            print("✅ 分类 [\(category)] 加载完成，共 \(playlist.count) 首歌曲")
            playlist.forEach { print("   🎵 \($0.lastPathComponent)") }
        }
        
        // 重置索引
        currentIndex = 0
    }
    
    // 播放当前索引的音乐
    func playCurrent() {
        guard !playlist.isEmpty else {
            print("❌ 播放列表为空，无法播放")
            return
        }
        
        // 确保索引有效
        if currentIndex >= playlist.count { currentIndex = 0 }
        
        let url = playlist[currentIndex]
        
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            // 如果已经在播放且是同一首，则不重新加载
            if let player = audioPlayer, player.url == url, player.isPlaying {
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 0 
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            currentTrackName = url.deletingPathExtension().lastPathComponent
            print("▶️ 正在播放: \(currentTrackName)")
            
        } catch {
            print("❌ 播放失败: \(error.localizedDescription)")
            // 尝试播放下一首（遇到损坏文件时自动跳过）
            playNext()
        }
    }
    
    // 播放下一首 (随机切换)
    func playNext() {
        guard !playlist.isEmpty else { return }
        
        if playlist.count > 1 {
            // 随机选择下一首，但尽量不重复当前这首
            var newIndex = Int.random(in: 0..<playlist.count)
            while newIndex == currentIndex {
                newIndex = Int.random(in: 0..<playlist.count)
            }
            currentIndex = newIndex
        } else {
            currentIndex = 0
        }
        
        playCurrent()
    }
    
    // 暂停/恢复
    func togglePlayPause() {
        guard let player = audioPlayer else {
            playCurrent() // 如果没有初始化，则初始化并播放
            return
        }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    // 停止
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("✅ 播放结束，自动随机播放下一首")
            playNext()
        }
    }
}

struct FocusPlayerView: View {
    // MARK: - Properties
    
    // 音频管理器
    @StateObject private var playerManager = AudioPlayerManager()
    
    // 入口传入的标题
    var title: String = "宇宙频率"
    // 分类 (用于加载对应文件夹的音乐)
    var category: String = ""
    
    // 回调：点击选择模式
    var onModeSelect: (() -> Void)?
    
    // 回调：返回
    var onBack: (() -> Void)?
    
    // 倒计时状态 (15分钟 = 900秒)
    @State private var timeRemaining: Int = 900
    @State private var isTimerRunning: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed Properties
    
    // 根据时间生成的副标题
    var timeBasedSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        // 调试输出
        print("Current hour: \(hour)")
        switch hour {
        case 5..<11: return "早上能量唤醒"
        case 11..<13: return "中午能量补充"
        case 13..<19: return "下午能量衰弱"
        default: return "晚上能量修复"
        }
    }
    
    // 格式化时间显示 MM:SS
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // 1. 背景层
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 背景图占位 (用户后续替换)
            Image("FocusPlayerBackground") // 需替换为真实图片名称
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            // 2. 主要内容层
            VStack(spacing: 0) {
                // 顶部标题区域
                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(timeBasedSubtitle)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.top, 100) // 调整顶部距离
                
                Spacer()
                
                // 倒计时和订阅按钮 (移至下方)
                VStack(spacing: 20) {
                    // 中间倒计时
                    Text(timeString)
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    // 订阅按钮
                    Button(action: {
                        print("Navigate to Membership Page")
                    }) {
                        Text("订阅获取无限时间")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 40)
                
                // 分割线
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 0.5)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 30)
                
                // 底部控制栏
                HStack(spacing: 60) {
                    // 左侧按钮 (返回/重置)
                    Button(action: {
                        playerManager.stop()
                        onBack?()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    }
                    
                    // 中间按钮 (播放/暂停)
                    Button(action: {
                        if timeRemaining == 0 {
                            timeRemaining = 900
                        }
                        playerManager.togglePlayPause()
                        isTimerRunning = playerManager.isPlaying
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // 右侧按钮 (随机切换)
                    Button(action: {
                        playerManager.playNext()
                    }) {
                        Image(systemName: "shuffle") // 改为随机图标
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
                
                // Home Indicator
                Capsule()
                    .fill(Color.white)
                    .frame(width: 134, height: 5)
                    .padding(.bottom, 8)
            }
        }
        #if os(iOS)
        .statusBar(hidden: true)
        #endif
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                isTimerRunning = false
                playerManager.stop()
            }
        }
        .onAppear {
            // 传入 category 加载音乐 (如果 category 为空，则使用 title 或默认值)
            let loadCategory = category.isEmpty ? "Focus" : category
            playerManager.loadPlaylist(category: loadCategory)
            playerManager.playCurrent()
        }
        .onDisappear {
            playerManager.stop()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 {
                        playerManager.stop()
                        onBack?()
                    }
                }
        )
    }
}

struct FocusPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        FocusPlayerView()
    }
}
