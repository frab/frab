터미널에서 아래 명령어 입력하여 모델에 position 컬럼 추가
```rails generate migration AddPositionToEventPeople position:integer```
```rails db:migrate```