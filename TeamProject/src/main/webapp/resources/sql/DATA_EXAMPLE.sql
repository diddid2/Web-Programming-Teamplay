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
