use KANGNAMTIME;
INSERT INTO member (USER_ID, USER_PW, NAME, MAJOR)
VALUES
('admin', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '교수님', '컴퓨터공학과'),
('user01', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정01', '소프트웨어학과'),
('user02', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정02', '컴퓨터공학과'),
('user03', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정03', '경영학과'),
('user04', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정04', '전자공학과'),
('user05', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정05', '기계공학과'),
('user06', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정06', 'AI융합학과'),
('user07', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정07', '산업경영공학과'),
('user08', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정08', '응용수학과'),
('user09', 'fe2592b42a727e977f055947385b709cc82b16b9a87f88c6abf3900d65d0cdc3', '테스트 계정09', '디자인학과');

INSERT INTO market_item
(title, category, price, status, campus, meeting_place, meeting_time, trade_type, wish_count, chat_count, thumbnail_url, description, writer_id, instant_buy)
VALUES
('사물인터넷 개론(개정3판) 팔아요', '교재 · 전공책', 12000, 'ON_SALE', '강남대 정문', '정문 CU 앞', '평일 18~21시', 'DIRECT', 3, 1, 'resources/MarketThumbnails/sample01.jpg',
 '수업 시간에 배웠던 곳은 문제 답 체크 되어있습니다. 거의 새책이에요.\n샤프로 체크한 거라 지우실 수 있어요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user02' LIMIT 1), 0),

('IFRS 중급회계 입문(제6판)', '교재 · 전공책', 15000, 'ON_SALE', '역 인근', '기흥역 4번 출구', '주말 아무때나', 'DIRECT', 2, 0, 'resources/MarketThumbnails/sample02.jpg',
 '답만 체크된 페이지 조금 있어요. 전체적으로 깨끗합니다.\n가격은 쿨거래 시 약간 네고 가능!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user07' LIMIT 1), 0),

('국제통상(무역) 교재 세트로 팝니다', '교재 · 전공책', 20000, 'ON_SALE', '강남대 정문', '정문 버스정류장', '평일 점심~저녁', 'BOTH', 5, 2, 'resources/MarketThumbnails/sample03.jpg',
 '무역상무론(1학기) + 교재/실용무역실무 + 비즈니스무역영어(2학기)\n한 번에 정리합니다. 개별도 문의주세요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user04' LIMIT 1), 0),

('실용무역실무 만원!', '교재 · 전공책', 10000, 'ON_SALE', '기숙사', '기숙사 로비', '오늘 20시 이후', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample04.jpg',
 '필기 거의 없고 상태 좋아요.\n글 있으면 계속 팝니다. 찜/채팅 주세요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user01' LIMIT 1), 0),

('마이크로컨트롤러 전공책', '교재 · 전공책', 30000, 'ON_SALE', '강남대 정문', '정문 스타벅스 앞', '평일 17시 이후', 'DIRECT', 4, 2, 'resources/MarketThumbnails/sample05.jpg',
 '전공 바꿔서 정리합니다.\n책 목록은 채팅 주시면 사진으로 보내드릴게요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user09' LIMIT 1), 0),

('기초 신호 및 시스템', '교재 · 전공책', 13000, 'RESERVED', '강남대 후문', '후문 카페 앞', '내일 14시', 'DIRECT', 6, 3, 'resources/MarketThumbnails/sample06.jpg',
 '겉표지 사용감 조금 있는데 내부는 깨끗해요.\n예약 중입니다!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user05' LIMIT 1), 0),

('공학용 계산기 팔아요', '전자기기', 15000, 'ON_SALE', '역 인근', '택배포장', NULL, 'DELIVERY', 7, 2, 'resources/MarketThumbnails/sample07.jpg',
 '시험 때만 잠깐 사용했어요. 작동 이상 없습니다.\n배터리도 아직 넉넉해요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user03' LIMIT 1), 1),

('USB-C 멀티허브(HDMI/USB) 급처', '전자기기', 9000, 'ON_SALE', '역 인근', '기흥역', '오늘 밤 가능', 'BOTH', 2, 1, 'resources/MarketThumbnails/sample08.jpg',
 '노트북 바꿔서 안 써서 내놔요.\nHDMI 출력/USB 인식 다 정상!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user08' LIMIT 1), 0),

('보조배터리 20000mAh (상태좋음)', '전자기기', 14000, 'ON_SALE', '기숙사', '기숙사 편의점 앞', '평일 19~22시', 'DIRECT', 3, 0, 'resources/MarketThumbnails/sample09.jpg',
 '충전 잘 되고 발열 거의 없어요.\n케이블은 필요하면 하나 같이 드릴게요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user06' LIMIT 1), 0),

('로지텍 G102 마우스', '전자기기', 12000, 'ON_SALE', '역 인근', '택배포장', NULL, 'DELIVERY', 2, 1, 'resources/MarketThumbnails/sample10.jpg',
 '게임용으로 썼고 클릭/휠 정상입니다.\n박스는 없어요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user02' LIMIT 1), 1),

('블루투스 키보드(텐키리스) 깔끔', '전자기기', 18000, 'ON_SALE', '강남대 후문', '후문 GS 앞', '평일 17시', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample11.jpg',
 '키감 괜찮고 배터리 오래가요.\n충전 케이블 포함!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user04' LIMIT 1), 0),

('공유기 하나 팝니다', '전자기기', 16000, 'ON_SALE', '역 인근', '기흥역', '주말 오후', 'BOTH', 2, 1, 'resources/MarketThumbnails/sample12.jpg',
 '기기 바꿔서 정리합니다. 초기화 해둘게요.\n구성품(어댑터) 다 있어요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user07' LIMIT 1), 0),

('전기포트 1L (자취 필수)', '자취템', 8000, 'ON_SALE', '기숙사', '기숙사 로비', '오늘 21시', 'DIRECT', 2, 0, 'resources/MarketThumbnails/sample13.jpg',
 '물 끓이는 용도로만 써서 깨끗해요.\n세척해두었습니다!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user01' LIMIT 1), 0),

('미니 밥솥 2~3인용', '자취템', 25000, 'ON_SALE', '강남대 정문', '정문 택시승강장', '평일 18시 이후', 'DIRECT', 4, 1, 'resources/MarketThumbnails/sample14.jpg',
 '혼자 살 때 잘 썼어요. 취사/보온 잘 됩니다.\n직거래만 가능!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user03' LIMIT 1), 0),

('원룸용 빨래건조대(접이식)', '자취템', 7000, 'ON_SALE', '강남대 후문', '후문', '저녁 가능', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample15.jpg',
 '공간 많이 안 차지하고 튼튼해요.\n생활기스 정도 있습니다.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user09' LIMIT 1), 0),

('책상 스탠드 LED(밝기 조절)', '자취템', 9000, 'ON_SALE', '강남대 정문', '정문 카페 앞', '평일 점심', 'BOTH', 2, 0, 'resources/MarketThumbnails/sample16.jpg',
 'USB 전원이고 눈부심 덜해요.\n필요하면 택배도 가능!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='admin' LIMIT 1), 0),

('미니 가습기(USB) 저렴', '자취템', 6000, 'RESERVED', '기숙사', '기숙사', '내일 20시', 'DIRECT', 3, 1, 'resources/MarketThumbnails/sample17.jpg',
 '한 철 사용했고 정상 작동합니다.\n예약중입니다!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user05' LIMIT 1), 0),

('3단 서랍장(플라스틱) 수납용', '자취템', 12000, 'ON_SALE', '강남대 정문', '정문', '주말만 가능', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample18.jpg',
 '깨진 곳 없고 수납 꽤 돼요.\n가지러 오셔야 합니다!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user06' LIMIT 1), 0),

('모니터 받침대(원목 느낌)', '자취템', 9000, 'ON_SALE', '역 인근', '택배포장', NULL, 'DELIVERY', 1, 0, 'resources/MarketThumbnails/sample19.jpg',
 '책상 정리하려고 샀는데 이제 안 써요.\n상태 좋아요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user08' LIMIT 1), 1),

('메모리폼 방석(의자용)', '자취템', 6000, 'ON_SALE', '기숙사', '기숙사 로비', '오늘 밤', 'DIRECT', 0, 0, 'resources/MarketThumbnails/sample20.jpg',
 '허리/엉덩이 덜 아파요. 커버 세탁해뒀습니다.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user02' LIMIT 1), 0),

('후드티 L (기본 검정)', '패션 · 잡화', 14000, 'ON_SALE', '강남대 정문', '정문', '평일 18시 이후', 'DIRECT', 2, 0, 'resources/MarketThumbnails/sample21.jpg',
 '두껍고 따뜻해요. 보풀 거의 없고 상태 괜찮습니다.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user04' LIMIT 1), 0),

('패딩 조끼 M (가볍게 입기 좋음)', '패션 · 잡화', 12000, 'ON_SALE', '강남대 후문', '후문 GS', '수업 끝나고', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample22.jpg',
 '한두 번 입고 옷장에만 있었어요.\n쿨거래 하시면 네고 가능!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user07' LIMIT 1), 0),

('백팩(노트북 수납 가능) 팝니다', '패션 · 잡화', 18000, 'ON_SALE', '역 인근', '기흥역', '주말', 'BOTH', 3, 1, 'resources/MarketThumbnails/sample23.jpg',
 '15인치 노트북 들어가고 수납 많아요.\n생활방수 됩니다.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user03' LIMIT 1), 0),

('텀블러 500ml (미사용)', '패션 · 잡화', 22000, 'ON_SALE', '강남대 정문', '정문 카페', '평일 점심', 'DIRECT', 2, 0, 'resources/MarketThumbnails/sample24.jpg',
 '선물 받았는데 안 써서 팝니다. 완전 새거예요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user01' LIMIT 1), 0),

('장우산(자동) 하나', '패션 · 잡화', 4000, 'ON_SALE', '강남대 정문', '정문', '아무때나 협의', 'DIRECT', 0, 0, 'resources/MarketThumbnails/sample25.jpg',
 '비 올 때만 써서 상태 괜찮아요.\n급하게 필요하신 분!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user06' LIMIT 1), 0),

('에어팟 2세대 케이스(정품)만', '패션 · 잡화', 9000, 'ON_SALE', '강남대 후문', '후문', '평일 17시', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample26.jpg',
 '케이스만 있습니다! 생활기스 조금 있어요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user09' LIMIT 1), 0),

('공학수학 교재 급처', '교재 · 전공책', 7000, 'ON_SALE', '강남대 정문', '정문 버스정류장', '평일 18시', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample27.jpg',
 '중요 부분 밑줄 조금 있어요. 과제용으로 괜찮습니다.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user08' LIMIT 1), 0),

('자료구조(C언어) 교재 팝니다', '교재 · 전공책', 8000, 'ON_SALE', '기숙사', '기숙사 로비', '오늘 22시', 'DIRECT', 1, 0, 'resources/MarketThumbnails/sample28.jpg',
 '필기 거의 없고 책 상태 좋아요.\n필요하시면 사진 더 보내드려요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user05' LIMIT 1), 0),

('운영체제(공룡책) 한글판', '교재 · 전공책', 18000, 'ON_SALE', '역 인근', '기흥역', '주말 오후', 'BOTH', 4, 2, 'resources/MarketThumbnails/sample29.jpg',
 '표지 사용감 조금 있는데 내부는 깔끔합니다.\n택배도 가능해요.',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user02' LIMIT 1), 0),

('무역영어 팝니다.', '교재 · 전공책', 6000, 'ON_SALE', '강남대 정문', '정문', '평일 점심', 'DIRECT', 0, 0, 'resources/MarketThumbnails/sample30.jpg',
 '단어 체크 흔적 조금 있어요.\n공부 시작하시는 분 가져가세요!',
 (SELECT MEMBER_NO FROM member WHERE USER_ID='user04' LIMIT 1), 0);

 INSERT INTO BOARD_POST (USER_ID, TITLE, CONTENT)
VALUES
('user02', '본인이 휴학생이라 그러는데', '오늘이 마지막 날임?
대부분 종강함?'),
('user05', '팀플', '팀플 첨인데 어렵나요?'),
('user01', '과제 제출 방식 뭐로 함', '한글로 올리려는데 ㄱㅊ?'),
('user09', '주말 스터디 모집합니다', '이번 주말에 도서관에서 같이 공부하실 분 구해요. 2~3시간 정도 생각 중입니다.'),
('user04', '출석/지각 기준 질문', '지각 몇 분부터 지각 처리되는지, 결석 기준이 어떻게 되는지 궁금합니다.'),
('user07', '한상진 교수님 웹 프로그래밍 강의 어떤가요??', '다음 학기때 한상진 교수님 웹프 수강하려는데 어떤가요 수강해보신 분 계신가요.'),
('user03', '중간고사 범위 예상', '중간고사 범위가 대략 1~6주차라는데, 연습문제 중 우선순위로 볼 파트가 있을까요?');


INSERT INTO BOARD_COMMENT (POST_NO, USER_ID, CONTENT)
VALUES
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user06', '오늘이 마지막 날이면 보통 기말고사/과제 마감 몰려있을 듯 ㅋㅋ'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user08', '과마다 달라요. 어떤 과목은 이미 종강했고 어떤 과목은 보강도 있음.'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user01', '대부분 종강 느낌인데 시험 남은 과목도 있더라'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user02', '처음이면 역할 분담만 잘해도 반은 먹고 들어감'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user07', '어렵다기보단 일정 관리가 제일 빡셈… 중간에 잠수타는 사람 나오면 지옥'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user09', '팀장 잡히면 좀 피곤한데 대신 점수는 안정적임'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user04', '한글 괜찮을 듯? 근데 교수님이 PDF 선호하실 수도'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user03', '깨질 때 있어서 PDF로 저장해서 올리는 게 안전함'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user05', '저는 보통 한글로 쓰고 PDF로 변환해서 제출함'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user01', '저 관심 있어요! 토/일 중에 어느 날 생각하세요?'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user02', '시간대랑 장소 정해지면 알려주세요'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user06', '도서관 자리 없으면 근처 스카도 ㄱㄴ'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user08', '수업마다 다르긴 한데 보통 10분 넘어가면 지각으로 치는 곳 많음'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user05', '출석 공지 확인해보면 적혀있을 수도 있어요'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user09', '저도 헷갈림… 공지로 정리되면 좋겠다'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user04', '나 찐따인데 교수님이 팀플 팀원 잡아주심 팀플 걱정 ㄴㄴ'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user02', '기말에 팀플이 있는데 듣기 괜찮음'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user07', '아주 배우기 쉽습니다.'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user01', '연습문제에서 자주 나오는 유형 위주로 보면 좋을 듯'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user06', '조인/정규화 이런 파트는 거의 필수로 나오는 느낌'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user03', '과제했던 코드 흐름 이해하고 가면 점수 잘 나옴');

INSERT IGNORE INTO BOARD_LIKE (POST_NO, USER_ID)
VALUES
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user01'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user06'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user08'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user02'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user07'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user09'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user03'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user05'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user01'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user02'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user06'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user05'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user08'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user02'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user04'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user09'),

((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user01'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user06');


INSERT IGNORE INTO BOARD_SCRAP (POST_NO, USER_ID)
VALUES
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='본인이 휴학생이라 그러는데' LIMIT 1), 'user04'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user01'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='팀플' LIMIT 1), 'user06'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='과제 제출 방식 뭐로 함' LIMIT 1), 'user02'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='주말 스터디 모집합니다' LIMIT 1), 'user03'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='출석/지각 기준 질문' LIMIT 1), 'user07'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='한상진 교수님 웹 프로그래밍 강의 어떤가요??' LIMIT 1), 'user05'),
((SELECT POST_NO FROM BOARD_POST WHERE TITLE='중간고사 범위 예상' LIMIT 1), 'user08');


UPDATE BOARD_POST p
SET
  COMMENT_COUNT = (SELECT COUNT(*) FROM BOARD_COMMENT c WHERE c.POST_NO = p.POST_NO),
  LIKE_COUNT    = (SELECT COUNT(*) FROM BOARD_LIKE l   WHERE l.POST_NO = p.POST_NO),
  SCRAP_COUNT   = (SELECT COUNT(*) FROM BOARD_SCRAP s  WHERE s.POST_NO = p.POST_NO);


INSERT INTO BOARD_NOTICE (USER_ID, TITLE, CONTENT)
VALUES
('admin', 'KangnamTime 시연 안내', '교수님 시연용으로 게시글/댓글/공감/스크랩 샘플 데이터가 포함되어 있습니다.\n기본 계정: admin, user01~user09'),
('admin', '게시판 이용 규칙', '비방/욕설/광고/개인정보 노출 글은 삭제될 수 있습니다.\n서로 예의 지켜주세요.'),
('admin', '중고거래 안전거래 안내', '직거래는 사람이 많은 곳에서 진행 권장.\n연락처/계좌 등 개인정보 공유는 주의해주세요.'),
('admin', '과제 캘린더 기능 안내', '과제 등록 후 마감일(D-DAY) 확인이 가능합니다.\n우선순위/상태도 함께 관리해보세요.');

