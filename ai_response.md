Viewed idea.md:1-13

[idea.md](file:///Users/satellite/수업/DockersAndGit/idea.md)에 작성된 내용을 잘 확인했습니다. **BUSOMAGO EC2**(가상 서버 대여 및 관리 서비스로 추정)의 MVP 발표를 위해, 기획하신 페이지와 SQL 테이블에서 보완해야 할 점들을 정리해 드립니다.

---

### 1. 페이지(Pages) 구성 보완점

현재 기획하신 4가지 페이지는 핵심 흐름을 잘 담고 있습니다. 다만, 실제 MVP 작동과 사용자 시나리오(UX Flow)를 자연스럽게 만들기 위해 다음 페이지 및 기능들이 추가/보완되어야 발표 시 완성도가 높아집니다.

*   **[보완/추가] 서버 신청/생성 폼 (또는 팝업)**
    *   *이유*: '가용 가능 서버 리스트'나 '유저 화면'에서 서버를 새로 대여하거나 생성하는 액션이 있어야 합니다. 
    *   *내용*: 서버 이름, 스펙(CPU, RAM, 용량), OS 이미지 선택 등의 입력 폼이 필요합니다.
*   **[보완/추가] 회원가입 페이지 (또는 간이 생성 기능)**
    *   *이유*: '로그인'이 있으므로, 사용자가 어떻게 계정을 생성하는지 혹은 관리자가 유저를 어떻게 추가하는지에 대한 흐름이 정의되어야 합니다.
*   **[상세화] 유저 화면 (서버 상태 관리, 비용관리)**
    *   발표 시 이 화면이 핵심(대시보드)이 될 것입니다.
    *   **서버 상태 제어 버튼**: 각 대여 서버의 '시작(Start)', '중지(Stop)', '터미네이트(삭제)' 버튼과 상태 표시(Running, Stopped, Pending 등).
    *   **비용 정보**: 이번 달 누적 사용 금액, 시간당 요금 등을 명시해야 비용관리 페이지로서 설득력을 가집니다.

---

### 2. SQL 테이블(Schema) 설계 보완점

기획하신 3가지 테이블(`서버`, `유저`, `비용청구`)을 기반으로 관계형 데이터베이스(RDB) 스키마를 구성할 때 빠진 핵심 필드(Column)와 테이블 간의 관계(FK)를 보완한 설계안입니다.

#### ① 유저 테이블 (`users`)
로그인 및 비용 청구의 주체가 됩니다.
```sql
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### ② 서버 템플릿/스펙 테이블 (`server_specs`) - *[추가 권장]*
'가용 가능한 서버의 리스트(스펙과 시간당 단가)'를 관리하기 위한 테이블입니다.
```sql
CREATE TABLE server_specs (
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    instance_type VARCHAR(50) NOT NULL, -- 예: 't3.micro', 'm5.large'
    cpu INT NOT NULL,                   -- vCPU 수
    ram_gb INT NOT NULL,                -- RAM 용량
    hourly_rate DECIMAL(10, 4) NOT NULL,-- 시간당 비용 (예: 0.0104)
    os_image VARCHAR(50) NOT NULL       -- Ubuntu, CentOS, Windows 등
);
```

#### ③ 유저 대여 서버 테이블 (`user_servers`) - *[보완]*
유저가 실제로 대여해서 사용 중인 서버 인스턴스 정보입니다. (서버 상태 관리의 대상)
```sql
CREATE TABLE user_servers (
    server_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    spec_id INT NOT NULL,
    server_name VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45) NULL,        -- 할당된 IP (대여 시 생성)
    status VARCHAR(20) DEFAULT 'pending', -- running, stopped, terminated 등
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (spec_id) REFERENCES server_specs(spec_id)
);
```

#### ④ 비용 청구/로그 테이블 (`billing_records`) - *[보완]*
서버 사용 시간에 비례해 비용이 누적되거나 청구되는 내역입니다. MVP에서는 간단히 서버 사용 로그 또는 월별 청구 테이블로 구성할 수 있습니다.
```sql
CREATE TABLE billing_records (
    billing_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    server_id INT NOT NULL,
    usage_hours DECIMAL(10, 2) NOT NULL, -- 사용 시간
    total_amount DECIMAL(10, 2) NOT NULL,-- 청구 금액 (사용시간 * 시간당 단가)
    billing_month VARCHAR(7) NOT NULL,   -- 청구 월 (예: '2026-05')
    is_paid BOOLEAN DEFAULT FALSE,       -- 납부 여부
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (server_id) REFERENCES user_servers(server_id)
);
```

---

### 발표(MVP) 준비 팁 💡
*   **시나리오 시연 구성**: 발표할 때 "1) 로그인 -> 2) 스펙 목록 보고 서버 신청 -> 3) 내 대시보드(유저 화면)에서 생성 중인 서버 확인 -> 4) 서버 중지/시작 조작 -> 5) 사용량에 따른 청구 비용 확인"의 흐름으로 데모를 보여주면 심사위원/청중이 쉽게 이해합니다.
*   **실제 작동 시뮬레이션**: 실제로 EC2 API를 연동하지 않더라도, DB의 `status` 값을 `running` <-> `stopped`로 바꾸는 API를 구현하여 화면 상에서 상태가 변하는 모습을 보여주면 훌륭한 MVP가 됩니다.