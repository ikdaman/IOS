import SwiftUI

// MARK: - Calendar Dropdown (팝업 내 인라인 드롭다운 달력)

struct RetroCalendarDropdown: View {
    @Binding var date: Date
    let onDismiss: () -> Void

    @State private var pending: Date

    init(date: Binding<Date>, onDismiss: @escaping () -> Void) {
        self._date = date
        self.onDismiss = onDismiss
        self._pending = State(initialValue: date.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            RetroCalendarView(date: $pending)
                .padding(8)
            Spacer().frame(height: 4)
            HStack {
                Spacer()
                Button("NO") { onDismiss() }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(Color.customBt)
                    .retroPixelBorder()
                Spacer().frame(width: 24)
                Button("YES") { date = pending; onDismiss() }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(Color.customBt)
                    .retroPixelBorder()
                Spacer()
            }
            Spacer().frame(height: 8)
        }
        .background(Color.customBg)
        .border(Color.black, width: 1)
    }
}

struct RetroCalendarDropdownOptional: View {
    @Binding var date: Date?
    let onDismiss: () -> Void

    @State private var pending: Date?
    private let initialDate: Date

    init(date: Binding<Date?>, initialDate: Date = Date(), onDismiss: @escaping () -> Void) {
        self._date = date
        self.initialDate = initialDate
        self.onDismiss = onDismiss
        self._pending = State(initialValue: date.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            RetroCalendarView(
                selectedDate: $pending,
                initialDisplayDate: pending ?? initialDate,
                allowDeselect: true
            )
            .padding(8)
            Spacer().frame(height: 4)
            HStack {
                Spacer()
                Button("NO") { onDismiss() }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(Color.customBt)
                    .retroPixelBorder()
                Spacer().frame(width: 24)
                Button("YES") { date = pending; onDismiss() }
                    .font(.customDungGeunMo(size: 12))
                    .foregroundColor(Color.customLb)
                    .padding(.horizontal, 16).padding(.vertical, 4)
                    .background(Color.customBt)
                    .retroPixelBorder()
                Spacer()
            }
            Spacer().frame(height: 8)
        }
        .background(Color.customBg)
        .border(Color.black, width: 1)
    }
}

// MARK: - Calendar Sheet (팝업 위에 표시되는 달력 오버레이)

struct RetroCalendarSheet: View {
    let initialDate: Date?
    let allowDeselect: Bool
    let onDismiss: () -> Void
    let onConfirm: (Date?) -> Void

    @State private var selectedDate: Date?

    init(
        initialDate: Date? = nil,
        allowDeselect: Bool = false,
        onDismiss: @escaping () -> Void,
        onConfirm: @escaping (Date?) -> Void
    ) {
        self.initialDate = initialDate
        self.allowDeselect = allowDeselect
        self.onDismiss = onDismiss
        self.onConfirm = onConfirm
        self._selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 0) {
                    // 타이틀 바
                    HStack(spacing: 0) {
                        Color.customBt
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.black, width: 1)
                        Button("X") { onDismiss() }
                            .font(.customDungGeunMo(size: 12))
                            .foregroundColor(Color.customLb)
                            .frame(width: 29, height: 28)
                            .background(Color.customBt)
                            .border(Color.black, width: 1)
                    }
                    .frame(height: 28)

                    VStack(spacing: 0) {
                        RetroCalendarView(
                            selectedDate: $selectedDate,
                            initialDisplayDate: initialDate ?? Date(),
                            allowDeselect: allowDeselect
                        )

                        Spacer().frame(height: 16)

                        HStack {
                            Spacer()
                            Button(action: { onDismiss() }) {
                                Text("NO")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer().frame(width: 50)
                            Button(action: { onConfirm(selectedDate) }) {
                                Text("YES")
                                    .font(.customDungGeunMo(size: 12))
                                    .foregroundColor(Color.customLb)
                                    .padding(.horizontal, 16).padding(.vertical, 4)
                                    .background(Color.customBt)
                                    .retroPixelBorder()
                            }
                            Spacer()
                        }

                        Spacer().frame(height: 16)
                    }
                    .padding(16)
                    .background(Color.customBg)
                }
                .retroPopupShadow()
                .padding(.horizontal, 16)
            }
    }
}

// MARK: - Calendar Picker

struct RetroCalendarView: View {
    @Binding var selectedDate: Date?
    let allowDeselect: Bool

    @State private var displayedMonth: Date

    private let cal = Calendar.current
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    /// Date? 바인딩 (FINISH처럼 선택 해제 가능한 날짜에 사용)
    init(selectedDate: Binding<Date?>, initialDisplayDate: Date = Date(), allowDeselect: Bool = false) {
        self._selectedDate = selectedDate
        self.allowDeselect = allowDeselect
        self._displayedMonth = State(initialValue: initialDisplayDate)
    }

    /// Date 바인딩 (START처럼 반드시 날짜가 있는 경우)
    init(date: Binding<Date>) {
        let optionalBinding = Binding<Date?>(
            get: { date.wrappedValue },
            set: { if let d = $0 { date.wrappedValue = d } }
        )
        self._selectedDate = optionalBinding
        self.allowDeselect = false
        self._displayedMonth = State(initialValue: date.wrappedValue)
    }

    private var year: Int { cal.component(.year, from: displayedMonth) }
    private var month: Int { cal.component(.month, from: displayedMonth) }

    private var daysInMonth: Int {
        cal.range(of: .day, in: .month, for: displayedMonth)!.count
    }

    private var firstWeekdayOffset: Int {
        var comps = cal.dateComponents([.year, .month], from: displayedMonth)
        comps.day = 1
        let first = cal.date(from: comps)!
        return (cal.component(.weekday, from: first) - 1 + 7) % 7
    }

    private func dateForDay(_ day: Int) -> Date {
        var comps = cal.dateComponents([.year, .month], from: displayedMonth)
        comps.day = day
        return cal.date(from: comps)!
    }

    private func isSelected(_ date: Date) -> Bool {
        selectedDate.map { cal.isDate(date, inSameDayAs: $0) } ?? false
    }

    var body: some View {
        VStack(spacing: 0) {
            // 월 헤더
            HStack {
                Button(action: {
                    displayedMonth = cal.date(byAdding: .month, value: -1, to: displayedMonth)!
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.customLb)
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Text(String(format: "%d년 %d월", year, month))
                    .font(.customDungGeunMo(size: 16))
                    .foregroundColor(Color.customLb)
                Spacer()
                Button(action: {
                    displayedMonth = cal.date(byAdding: .month, value: 1, to: displayedMonth)!
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.customLb)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 8)

            Spacer().frame(height: 8)

            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.customSansRegular(size: 10))
                        .foregroundColor(Color.customLb)
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer().frame(height: 8)

            // 날짜 그리드
            let totalCells = firstWeekdayOffset + daysInMonth
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<totalCells, id: \.self) { index in
                    if index < firstWeekdayOffset {
                        Color.clear.frame(height: 33)
                    } else {
                        let day = index - firstWeekdayOffset + 1
                        let date = dateForDay(day)
                        let selected = isSelected(date)

                        Button(action: {
                            if allowDeselect && selected {
                                selectedDate = nil
                            } else {
                                selectedDate = date
                            }
                        }) {
                            ZStack {
                                if selected {
                                    Rectangle()
                                        .fill(Color.customBt)
                                        .frame(width: 25, height: 25)
                                }
                                Text("\(day)")
                                    .font(.customSansRegular(size: 14))
                                    .foregroundColor(Color.customLb)
                            }
                        }
                        .frame(height: 33)
                    }
                }
            }
        }
    }
}
