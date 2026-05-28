CREATE TABLE user
(
  user_id    INTEGER     NOT NULL AUTO_INCREMENT COMMENT '고유 식별자',
  username   VARCHAR(64) NOT NULL UNIQUE COMMENT 'Login ID',
  password   VARCHAR(64) NOT NULL COMMENT 'SHA-256으로 해싱된 PW',
  role       VARCHAR(10) NULL     DEFAULT 'USER' COMMENT '권한',
  status     TINYINT     NULL     DEFAULT 1 COMMENT '1 : ACTIVE, 2 : INACTIVE, 3: BANNED',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
  PRIMARY KEY (user_id)
);

CREATE TABLE server_spec
(
  id         INTEGER     NOT NULL AUTO_INCREMENT COMMENT '서버 고유 ID',
  name       VARCHAR(50) NULL     DEFAULT 'Linux server' COMMENT '서버의 이름',
  pr_name    VARCHAR(50) NULL     DEFAULT 'Intel® Xeon® Gold 6544Y' COMMENT '프로세서 이름',
  pr_core    INTEGER     NULL     DEFAULT 16 COMMENT '프로세서 코어 수',
  ram_gb     INTEGER     NOT NULL DEFAULT 16 COMMENT '메모리 용량',
  storage_gb INTEGER     NOT NULL DEFAULT 128 COMMENT '저장장치 용량',
  cost       FLOAT       NULL     DEFAULT 0.0 COMMENT '시간당 비용($)',
  PRIMARY KEY (id)
);

CREATE TABLE instance
(
  id            INTEGER     NOT NULL AUTO_INCREMENT COMMENT '인스턴스의 고유 ID',
  user_id       INTEGER     NOT NULL COMMENT '고유 식별자',
  server_id     INTEGER     NOT NULL COMMENT '서버 고유 ID',
  instance_name VARCHAR(30) NULL     DEFAULT 'My Server' COMMENT '인스턴스의 이름',
  ip_address    VARCHAR(40) NOT NULL DEFAULT '192.168.75.1' COMMENT 'IP 주소',
  status        INTEGER     NOT NULL DEFAULT 0 COMMENT '0 : Down 1 : Up 2 : Stop 3 : Terminated',
  created_at    DATETIME    NULL     DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (server_id) REFERENCES server_spec (id)
);

CREATE TABLE billing
(
  id          INTEGER  NOT NULL AUTO_INCREMENT COMMENT '결제 id',
  user_id     INTEGER  NOT NULL COMMENT '고유 식별자',
  instance_id INTEGER  NOT NULL COMMENT '인스턴스의 고유 ID',
  amount      FLOAT    NOT NULL DEFAULT 0.0 COMMENT '청구 금액($)',
  start_at    DATETIME NULL     COMMENT '인스턴스 산정 시작 시점',
  end_at      DATETIME NULL     COMMENT '인스턴스 산정 종료 시점',
  status      INTEGER  NOT NULL DEFAULT 1 COMMENT '0 : FAIL 1 : PENDING 2 : PAID',
  pay_at      DATETIME NULL     COMMENT '결제 일시',
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES user (user_id),
  FOREIGN KEY (instance_id) REFERENCES instance (id)
);
