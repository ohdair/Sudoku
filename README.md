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

### 
