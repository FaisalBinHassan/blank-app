import SwiftUI

// MARK: - QWERTY Layout

struct QWERTYKeyboard: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let needsGlobe: Bool

    private let row1 = ["q","w","e","r","t","y","u","i","o","p"]
    private let row2 = ["a","s","d","f","g","h","j","k","l"]
    private let row3 = ["z","x","c","v","b","n","m"]

    var body: some View {
        GeometryReader { geo in
            let keyW = geo.size.width / 10 - 6
            VStack(spacing: 8) {
                // Row 1
                HStack(spacing: 5) {
                    ForEach(row1, id: \.self) { key in
                        letterKey(key, width: keyW)
                    }
                }

                // Row 2 (slightly inset)
                HStack(spacing: 5) {
                    Spacer(minLength: keyW * 0.5)
                    ForEach(row2, id: \.self) { key in
                        letterKey(key, width: keyW)
                    }
                    Spacer(minLength: keyW * 0.5)
                }

                // Row 3: Shift + letters + delete
                HStack(spacing: 5) {
                    shiftKey(width: keyW * 1.5)
                    Spacer(minLength: 4)
                    ForEach(row3, id: \.self) { key in
                        letterKey(key, width: keyW)
                    }
                    Spacer(minLength: 4)
                    deleteKey(width: keyW * 1.5)
                }

                // Row 4: 123 / Globe / Space / Return
                HStack(spacing: 5) {
                    modeKey(label: "123", width: keyW * 1.5) {
                        viewModel.keyboardMode = .numbers
                    }
                    if needsGlobe {
                        globeKey(width: keyW)
                    }
                    micKey(width: keyW)
                    spaceKey
                    returnKey(width: keyW * 1.8)
                }
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Key builders

    private func letterKey(_ key: String, width: CGFloat) -> some View {
        let label = viewModel.isUppercase || viewModel.isCapsLock ? key.uppercased() : key
        return KeyButton(label: label, width: width, style: .letter) {
            viewModel.insertText(label)
        }
    }

    private func shiftKey(width: CGFloat) -> some View {
        let icon: String
        if viewModel.isCapsLock {
            icon = "capslock.fill"
        } else if viewModel.isUppercase {
            icon = "shift.fill"
        } else {
            icon = "shift"
        }
        return KeyButton(
            systemImage: icon,
            width: width,
            style: viewModel.isUppercase || viewModel.isCapsLock ? .action : .function
        ) {
            viewModel.tapShift()
        }
    }

    private func deleteKey(width: CGFloat) -> some View {
        KeyButton(systemImage: "delete.left", width: width, style: .function) {
            viewModel.deleteBackward()
        }
    }

    private func modeKey(label: String, width: CGFloat, action: @escaping () -> Void) -> some View {
        KeyButton(label: label, width: width, style: .function, action: action)
    }

    private func globeKey(width: CGFloat) -> some View {
        KeyButton(systemImage: "globe", width: width, style: .function) {
            viewModel.switchToNextKeyboard()
        }
    }

    private func micKey(width: CGFloat) -> some View {
        KeyButton(systemImage: "mic", width: width, style: .function) {
            // Signals iOS to switch to dictation
            viewModel.switchToNextKeyboard()
        }
    }

    private var spaceKey: some View {
        KeyButton(label: "space", width: nil, style: .space) {
            viewModel.insertSpace()
        }
    }

    private func returnKey(width: CGFloat) -> some View {
        KeyButton(label: "return", width: width, style: .function) {
            viewModel.insertNewline()
        }
    }
}

// MARK: - Numbers Keyboard

struct NumbersKeyboard: View {
    @ObservedObject var viewModel: KeyboardViewModel
    let needsGlobe: Bool
    @State private var showSymbols = false

    private let numRow1 = ["1","2","3","4","5","6","7","8","9","0"]
    private let numRow2 = ["-","/",":",";","(",")",  "$","&","@","\""]
    private let numRow3 = [".",",","?","!","'"]

    private let symRow1 = ["[","]","{","}","#","%","^","*","+","="]
    private let symRow2 = ["_","\\","|","~","<",">","€","£","¥","•"]
    private let symRow3 = [".",",","?","!","'"]

    var body: some View {
        GeometryReader { geo in
            let keyW = geo.size.width / 10 - 6
            VStack(spacing: 8) {
                let r1 = showSymbols ? symRow1 : numRow1
                let r2 = showSymbols ? symRow2 : numRow2
                let r3 = showSymbols ? symRow3 : numRow3

                HStack(spacing: 5) {
                    ForEach(r1, id: \.self) { key in
                        KeyButton(label: key, width: keyW, style: .letter) { viewModel.insertText(key) }
                    }
                }
                HStack(spacing: 5) {
                    ForEach(r2, id: \.self) { key in
                        KeyButton(label: key, width: keyW, style: .letter) { viewModel.insertText(key) }
                    }
                }
                HStack(spacing: 5) {
                    KeyButton(label: showSymbols ? "123" : "#+=", width: keyW * 1.5, style: .function) {
                        showSymbols.toggle()
                    }
                    Spacer(minLength: 4)
                    ForEach(r3, id: \.self) { key in
                        KeyButton(label: key, width: keyW, style: .letter) { viewModel.insertText(key) }
                    }
                    Spacer(minLength: 4)
                    KeyButton(systemImage: "delete.left", width: keyW * 1.5, style: .function) {
                        viewModel.deleteBackward()
                    }
                }
                HStack(spacing: 5) {
                    KeyButton(label: "ABC", width: keyW * 1.5, style: .function) {
                        viewModel.keyboardMode = .letters
                    }
                    if needsGlobe {
                        KeyButton(systemImage: "globe", width: keyW, style: .function) {
                            viewModel.switchToNextKeyboard()
                        }
                    }
                    KeyButton(label: "space", width: nil, style: .space) {
                        viewModel.insertSpace()
                    }
                    KeyButton(label: "return", width: keyW * 1.8, style: .function) {
                        viewModel.insertNewline()
                    }
                }
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - KeyButton

enum KeyStyle {
    case letter, function, space, action
}

struct KeyButton: View {
    var label: String?
    var systemImage: String?
    var width: CGFloat?
    var style: KeyStyle
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Group {
                if let img = systemImage {
                    Image(systemName: img)
                        .font(.system(size: 16, weight: .regular))
                } else {
                    Text(label ?? "")
                        .font(.system(size: style == .letter ? 18 : 14, weight: style == .letter ? .regular : .medium))
                }
            }
            .frame(maxWidth: width ?? .infinity, minHeight: 42)
            .background(keyBackground)
            .foregroundColor(keyForeground)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeIn(duration: 0.05)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = false } }
        )
    }

    @ViewBuilder
    private var keyBackground: some View {
        switch style {
        case .letter:
            Color(.systemBackground)
        case .function:
            Color(.systemGray3)
        case .space:
            Color(.systemBackground)
        case .action:
            Color.blue
        }
    }

    private var keyForeground: Color {
        switch style {
        case .action: return .white
        default: return .primary
        }
    }
}
