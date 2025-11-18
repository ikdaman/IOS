//
//  MyViewModel.swift
//  Ikdaman
//
//  Created by 이재혁 on 3/3/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct MyViewModelInput {
    let viewDidLoad: Observable<Void>
    let alarmToggleChanged: Observable<Bool>
    let alarmTimeTapped: Observable<Void>
}

struct MyViewModelOutput {
    var sections: Observable<[Section]>
    var showTimePicker: Observable<Void>
}

protocol MyViewModel {
    // MARK: - Binding
    func transform(input: MyViewModelInput) -> MyViewModelOutput
    
    // 기능 인터페이스 추가
}

// [END] Interface

final class DefaultMyViewModel: MyViewModel {
    private var disposeBag = DisposeBag()
    
    private var sections = BehaviorRelay<[Section]>(value: [])
    private let showTimePickerRelay = PublishRelay<Void>()
    
    func transform(input: MyViewModelInput) -> MyViewModelOutput {
        input.viewDidLoad
            .subscribe(onNext: {
                self.setupTableView()
                
                let isOn = UserDefaults.standard.bool(forKey: "alarmToggle")
                if isOn {
                    let hour = UserDefaults.standard.integer(forKey: "alarmHour")
                    let minute = UserDefaults.standard.integer(forKey: "alarmMinute")
                    UserNotificationService.shared.scheduleDailyNotification(hour: hour, minute: minute)
                }
            })
            .disposed(by: disposeBag)
        
        input.alarmToggleChanged
            .subscribe(onNext: { isOn in
                if isOn {
                    // 기본 설정 시간 로드 (예: 09:00)
                    let hour = UserDefaults.standard.integer(forKey: "alarmHour")
                    let minute = UserDefaults.standard.integer(forKey: "alarmMinute")
                    
                    UserNotificationService.shared.scheduleDailyNotification(hour: hour, minute: minute)
                } else {
                    UserNotificationService.shared.cancelDailyNotification()
                }
            })
            .disposed(by: disposeBag)
        
        input.alarmTimeTapped
            .bind(to: showTimePickerRelay)
            .disposed(by: disposeBag)
        
        return MyViewModelOutput(
            sections: sections.asObservable(),
            showTimePicker: showTimePickerRelay.asObservable()
        )
    }
    
}

extension DefaultMyViewModel {
    private func setupTableView() {
        let sectionData = [
            Section(items: [.arrow(title: "내 정보 관리")]),
            Section(items: [
                .alarm
            ]),
            Section(items: [
                .arrow(title: "공지사항"),
                .arrow(title: "서비스 이용약관"),
                .arrow(title: "개인정보 처리방침"),
                .arrow(title: "1:1 문의")
            ])
        ]
        
        sections.accept(sectionData)
    }
}

enum CellType {
    case arrow(title: String)
    case alarm
}

struct Section {
    var items: [CellType]
}
