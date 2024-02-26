# Sudoku
MVC패턴으로 작성된 코드를 RxSwift 적용하여 MVVM으로 리팩터링한 스도쿠 게임

## UI 설계 및 플로우에 따른 다이어그램
<img width="600" src="https://github.com/ohdair/Sudoku/assets/79438622/204986c7-ea57-49ee-9619-17d68af783b6">
<img width="600" alt="스크린샷 2024-02-25 오후 5 16 44" src="https://github.com/ohdair/Sudoku/assets/79438622/223b730b-3a3e-4346-b2c7-5617611a56a2">

## 메인화면
`func viewWillAppear()` 뷰가 보여지기 전에 UserDefault에 저장된 게임 데이터가 있다면
데이터를 불러와서 `이어하기 버튼`이 보여지도록 설정
데이터가 없다면 `시작하기 버튼`만 존재

RxCocoa를 사용해 tap 제스처가 발생하면 GameViewController로 넘어갈 수 있도록 bind
```swift
private func bind() {
    newGameButton.rx.tap
        .asDriver()
        .drive { _ in
            let gameViewController = GameViewController()
            self.navigationController?.pushViewController(gameViewController, animated: true)
        }
        .disposed(by: disposeBag)

    continueGameButton.rx.tap
        .asDriver()
        .drive { _ in
            let gameViewModel = GameViewModel(sudoku: self.savedGame!)
            let gameViewController = GameViewController(viewModel: gameViewModel)

            self.navigationController?.pushViewController(gameViewController, animated: true)
        }
        .disposed(by: disposeBag)
}
```

## 게임화면
화면 내 많은 버튼 및 뷰가 존재하며 각각 뷰에서 필요한 정보들을 전달
1. 일시정지 및 뒤로가기
2. 게임의 정보들을 보여주는 뷰
3. `9 * 9`로 이뤄진 보드 뷰
4. 게임의 데이터를 조정 및 입력을 조정하는 버튼들
5. 보드 판 내에 입력할 수 있도록 하는 숫자 버튼들

### Input & Output 디자인 패턴을 사용하여 ViewModel 생성
#### InformationViewModel
게임 진행에 사용된 시간 측정은 `Driver<Int>.interval`을 사용

```swift
final class InformationViewModel: ViewModelType {

    struct Input {
        var difficulty: Observable<GameDifficulty>
        var mistake: Observable<Int>
        var mistakeTrigger: Observable<Void>
        var time: Observable<TimeInterval>
        var timerTrigger: Driver<Void>
    }

    struct Output {
        var difficulty: Driver<String>
        var mistake: Driver<Int>
        var time: Driver<TimeInterval>
    }

    private let time = BehaviorRelay<TimeInterval>(value: 0)
    private let isOnTimer = BehaviorRelay<Bool>(value: false)

    func transform(input: Input) -> Output {
        // ...
        Driver<Int>
            .interval(.seconds(1))
            .filter { _ in self.isOnTimer.value }
            .drive { _ in
                self.updateTimer()
            }
            .disposed(by: disposeBag)
        // ...
    }
}
```
#### BoardViewModel
보드판에서 고려할 대상들
1. 보드판에 입력된 커서 유/무
2. 메모의 기능 On/Off
3. 입력받은 숫자
4. 커서에 따른 연관된 보드판 내 셀들
5. 입력받은 숫자와 연관된 보드판 내 셀들
6. mistake가 되는지 판단

보드의 정보가 바뀔 때, 보드판의 커서를 선택에 따른 연관된 보드판을 반응형으로 표현하기 위해
RxSwift의 `withLatestFrom`와 `compactMap`을 사용하여 값이 존재할 때에만 셀의 배경 및 텍스트 변경할 수 있도록 구독
```swift
input.board
    .withLatestFrom(cursor)
    .compactMap { $0 }
    .subscribe { ... }
```

Output으로 Board 정보를 내보낼 때, 연관된 지우기 기능으로 셀을 지우거나 메모를 입력 그리고 숫자를 입력하는 경우
하나의 데이터로 묶어서 값을 내보내기 위해 Driver.merge를 사용
```swift
Output(
    board: Driver.merge(updatedBoardToErase, updatedBoardToMemo, updatedBoardToNumber)
    // ...
)
```

정보들의 연관관계가 많은만큼 `filter`와 `compactMap`와 같이 데이터의 변경 등을 확인하여 동작되도록 설정

#### AbilityViewModel
보드판의 정보를 기록하는 `Stack` 형식으로 구현하여 뒤로가기 기능을 구현
```swift
private func pushBoard(_ board: Board) { ... }

private func undoBoard() -> Board { ... }

private func reset() { ... }
```
