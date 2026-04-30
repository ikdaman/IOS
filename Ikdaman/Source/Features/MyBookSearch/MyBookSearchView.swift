import SwiftUI

struct MyBookSearchView: View {
    @StateObject private var viewModel = MyBookSearchViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(title: "내 책 검색", showBackButton: true)

            // 검색 바
            HStack(spacing: 0) {
                TextField("책 제목을 검색해주세요.", text: $viewModel.query)
                    .font(.customRegular(size: 14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .onSubmit {
                        Task { await viewModel.search() }
                    }

                Button(action: {
                    Task { await viewModel.search() }
                }) {
                    Image("search")
                        .padding(.horizontal, 12)
                }
            }
            .overlay(Rectangle().stroke(Color.customLb, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // 결과 리스트
            ScrollView {
                LazyVStack(spacing: 30) {
                    ForEach(viewModel.results, id: \.mybookId) { item in
                        NavigationLink(value: item.mybookId) {
                            SearchResultRow(item: item, statusLabel: viewModel.statusLabel(item.readingStatus))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 30)
            }

            Spacer(minLength: 0)
        }
        .background(Color.customBg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - SearchResultRow

private struct SearchResultRow: View {
    let item: MyBookSearchItemResponse
    let statusLabel: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 이미지: 86x120
            AsyncImage(url: URL(string: item.bookInfo.coverImage ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 86, height: 120)
                        .clipped()
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 86, height: 120)
                }
            }
            .frame(width: 86, height: 120)

            // 콘텐츠: 이미지에서 오른쪽 28
            VStack(alignment: .leading, spacing: 0) {
                // 현재 상태 라벨: 셀 위에서 2, 높이 25
                Text(statusLabel)
                    .font(.customDungGeunMo(size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .frame(height: 25)
                    .background(statusColor(statusLabel))
                    .padding(.top, 2)

                // 책 제목: 라벨 bottom + 8, 오른쪽 10 패딩
                Text(item.bookInfo.title)
                    .font(.customSemiBold(size: 14))
                    .foregroundColor(Color.customLb)
                    .lineLimit(2)
                    .padding(.top, 8)
                    .padding(.trailing, 10)

                // 작가: 제목 bottom + 12
                Text(item.bookInfo.author.joined(separator: ", "))
                    .font(.customRegular(size: 12))
                    .foregroundColor(Color.customLb.opacity(0.7))
                    .lineLimit(1)
                    .padding(.top, 12)

                Spacer(minLength: 0)
            }
            .padding(.leading, 28)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .padding(.horizontal, 16)
        .background(Color.clear)
    }

    private func statusColor(_ label: String) -> Color {
        switch label {
        case "읽고 싶은 책": return Color.blue
        case "읽는 중":     return Color(r: 80, g: 160, b: 120)
        case "완독":        return Color(r: 100, g: 100, b: 100)
        default:            return Color.gray
        }
    }
}
