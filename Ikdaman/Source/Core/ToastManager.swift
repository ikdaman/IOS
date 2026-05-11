import SwiftUI

@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    @Published var message: String? = nil
    private var dismissTask: Task<Void, Never>?
    private init() {}

    func show(_ message: String) {
        self.message = message
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            self.message = nil
        }
    }
}

struct ToastOverlayModifier: ViewModifier {
    @ObservedObject private var manager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let msg = manager.message {
                Text(msg)
                    .font(.customSansRegular(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.82))
                    .cornerRadius(4)
                    .padding(.bottom, 80)
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: manager.message)
    }
}

extension View {
    func withToast() -> some View {
        modifier(ToastOverlayModifier())
    }
}
