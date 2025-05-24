---
layout: post
category: book
tags: ["data-intensive-applications", 'data-engineering']
---

<!-- TOC -->
* [2장 데이터 모델과 질의 언어](#2장-데이터-모델과-질의-언어)
  * [관계형 모델과 문서 모델](#관계형-모델과-문서-모델)
    * [NoSQL의 탄생](#nosql의-탄생)
    * [객체 관계형 불일치](#객체-관계형-불일치)
    * [다대일과 다대다 관계](#다대일과-다대다-관계)
    * [문서 데이터베이스는 역사를 반복하고 있나?](#문서-데이터베이스는-역사를-반복하고-있나)
      * [네트워크 모델](#네트워크-모델)
      * [관계형 모델](#관계형-모델)
    * [문서 데이터베이스와의 비교](#문서-데이터베이스와의-비교)
    * [관계형 데이터베이스와 오늘날의 문서 데이터베이스](#관계형-데이터베이스와-오늘날의-문서-데이터베이스)
      * [어떤 데이터 모델이 애플리케이션 코드를 더 간단하게 할까?](#어떤-데이터-모델이-애플리케이션-코드를-더-간단하게-할까)
      * [문서 모델에서의 스키마 유연성](#문서-모델에서의-스키마-유연성)
      * [질의를 위한 데이터 지역성](#질의를-위한-데이터-지역성)
      * [문서 데이터베이스와 관계형 데이터베이스의 통합](#문서-데이터베이스와-관계형-데이터베이스의-통합)
  * [데이터를 위한 질의 언어](#데이터를-위한-질의-언어)
    * [웹에서의 선언형 질의](#웹에서의-선언형-질의)
    * [맵리듀스 질의](#맵리듀스-질의)
  * [그래프형 데이터 모델](#그래프형-데이터-모델)
    * [속성 그래프](#속성-그래프)
    * [사이퍼 질의 언어](#사이퍼-질의-언어)
    * [SQL의 그래프 질의](#sql의-그래프-질의)
    * [트리플 저장소와 스파클](#트리플-저장소와-스파클)
      * [시맨틱 웹](#시맨틱-웹)
      * [RDF 데이터 모델](#rdf-데이터-모델)
      * [스파클 질의 언어](#스파클-질의-언어)
    * [초석: 데이터로그](#초석-데이터로그)
  * [정리](#정리)
<!-- TOC -->

# 2장 데이터 모델과 질의 언어

데이터 모델은 중요하다. 왜냐하면 소프트웨어가 어떻게 작성됐는지 뿐만 아니라 해결하려는 **문제를 어떻게 생각해야 하는지**에
대해서도 지대한 영향을 미치기 때문이다.

대부분의 애플리케이션은 하나의 데이터 모델을 다른 데이터 모델 위에 계층을 둬서 만든다. 각 계층의 핵심적인 문제는 다음 하위 계층 관점에서
데이터 모델을 **표현**하는 방법이다. 예를 들어보자.
- 애플리케이션 개발자는 현실(사람, 조직, 상품 등)을 보고 객체나 데이터 구조, 그리고 이러한 데이터 구조를 다루는 API를 모델링한다.
이런 구조는 보통 애플리케이션에 특화돼 있다.
- 데이터 구조를 저장할 때는 JSON이나 XML 문서, 관계형 데이터베이스 테이블이나 그래프 모델 같은 범용 데이터 모델로 표현한다.
- 데이터베이스 소프트웨어를 개발하는 엔지니어는 JSON / XML / 관계형 / 그래프 데이터를 메모리나 디스크 또는
네트워크 상의 바이트 단위로 표현하는 방법을 결정한다. 이 표현은 다양한 방법으로 데이터를 질의, 탐색, 조작, 처리할 수 있게 한다.
- 더 낮은 수준에서 하드웨어 엔지니어는 전류, 빛의 파동, 자기장 등의 관점에서 바이트를 표현하는 방법을 알아냈다.

| 계층                | 주체         | 관찰대상                    | 데이터 모델 표현 방법                       | 표현 목적 / 특징                               |
|-------------------|------------|-------------------------|------------------------------------|------------------------------------------|
| 현실 세계             | 사용자 / 기획자  | 현실(사람, 조직, 상품 등)        | 현실 개념                              | 실제 현상을 추상화하고 시스템화                        |
| 애플리케이션            | 애플리케이션 개발자 | 객체, 데이터 구조              | API                                | 기능 구현을 위한 추상화된 데이터 표현                    |
| **저장 계층**             | **서버 개발자**     | **구조화된 데이터**                | **JSON, XML 문서, 관계형 데이터베이스 테이블, 그래프 모델** | **범용 데이터 모델로 표현**                            |
| DB 내부 표현 계층 | DBMS 개발자   | JSON, XML, 관계형, 그래프 데이터 | 메모리, 디스크 또는 네트워크 상의 바이트 단위로 표현     | 다양한 방법으로 데이터를 질의, 탐색, 조작 처리 가능하도록 설계 해야함 |
| 하드웨어              | 하드웨어 엔지니어  | 바이트       | 전류, 빛의 파동, 자기장                                |                                          |

이번 장에서는 데이터 저장과 질의(표의 **저장 계층** 항목)를 위한 다양한 범용 데이터 모델을 살펴본다.
특히 relational model과 document model, 그리고 몇 가지 graph-based data model을 비교한다.
또한 다양한 질의 언어를 살펴보고 사용 사례도 비교한다.

## 관계형 모델과 문서 모델

가장 잘 알려진 모델은 관계형 모델을 기반으로 한 SQL이다. 데이터는 **관계(relation (sql에서 테이블))** 로 구성되고
각 관계는 순서 없는 **튜플(tuple) (sql에서 row))** 모음이다.

관계형 모델은 이론적 제안이었음. 이론대로 구현할 수 있는지 의문이었지만 1980년대 중반에 RDBMS와 SQL은
정규화된 구조로 데이터를 저장하고 질의할 필요가 있는 사람들 대부분이 선택하는 도구가 되었음.

관계형 데이터베이스의 근원은 1960년대와 70년대에 메인프레임 컴퓨터에서 수행된 **비즈니스 데이터 처리**에 있다.
이 사용 사례는 보통 **트랜잭션 처리**(영업이나 은행 거래, 항공 예약, 창고에 재고 보관)와 **일괄 처리**
(고객 송장 작성, 급여 지불, 보고)로 오늘날의 관점에서는 일상적으로 수행되는 일이다.

### NoSQL의 탄생

2010년대에 **NoSQL**은 관계형 모델의 우위를 뒤집으려는 가장 최신 시도다.
NOSQL 데이터베이스 채택한 데는 다음과 같은 다양한 원동력이 있다.
- 대규모 데이터셋이나 매우 높은 쓰기 처리량 달성을 관계형 데이터베이스보다 쉽게 할 수 있는 뛰어난 확장성의 필요
- 상용 데이터베이스 제품보다 무료 오픈소스 소프트웨어에 대한 선호도 확산
- 관계형 모델에서 지원하지 않는 특수 질의 동작
- 관계형 스키마의 제한에 대한 불만과 더욱 동적이고 표현력이 풍부한 데이터 모델에 대한 바람

가까운 미래에는 관계형 데이터베이스가 폭넓은 다양함을 가진 비관계형 데이터스토어와 함께 사용될 것이다.
이런 개념을 종종 **다중 저장소 지속성(polyglot persistence)** 이라고 부른다.

### 객체 관계형 불일치

오늘날 대부분의 애플리케이션은 객체지향 프로그래밍 언어로 개발한다. 데이터를 관계형 테이블에 저장하려면
애플리케이션 코드와 데이터 베이스 모델 객체(테이블, 로우, 칼럼) 사이에 거추장스러운 전환 계층이 필요하다.
이런 모델 사이의 분리를 종종 **임피던스 불일치(impedance mismatch)** 라고 부른다.

액티브레코드나 하이버네이트 같은 객체 관계형 매핑(ORM) 라이브러리는 전환 계층에 필요한 상용구 코드의 양을
줄이지만 두 모델 간의 차이를 완벽히 숨길 수 없다.

링크드인 이력서 저장을 위한 데이터 모델을 생각해보자. 경력에 넣을 직업이 하나 이상이며 학력 기간과 연락처 정보도
다양하다. 사용자와 이들 항목은 일대다(one-to-many) 관계를 가진다.

이력서 같은 데이터 구조는 모든 내용을 갖추고 있는 문서라서 JSON 표현에 매우 적합하다.

**예제 2-1**. JSON 문서로 표현한 링크드인 프로필
```json
{
  "user_id": 251, "first_name": "Bill",
  "last_name": "Gates",
  "summary": "Co-chair of the Bill & Melinda Gates Foundation",
  "region_id": "us:91",
  "industry_id": 131,
  "photo_url": "/p/7/000/253/05b/308dd6e.jpg",
  "positions": [
    {"job_title": "Co-chair", "organization": "Bill & Melinda Gates Foundation"},
    {"job_title": "Co-founder, Chairman", "organization": "Microsoft"}
  ],
  "education": [
    {"school_name": "Harvard University", "start": 1973, "end": 1975},
    {"school_name": "Lakeside School, Seattle", "start": null, "end": null}
  ],
  "contact_info": {
    "blog": "http://thegatesnotes.com",
    "twitter": "http://twitter.com/BillGates"
  } 
}
```
JSON 표현은 다중 테이블 스키마보다 더 나은 **지역성(locality)** 을 갖는다. 관계형 예제에서 프로필을
가져오려면 다중 질의(각 테이블에 user_id로 질의)를 수행하거나 users 테이블과 그 하위 테이블 간에 난잡한
다중 조인을 수행해야 한다.

하지만 JSON 표현에서는 모든 관련 정보가 한 곳에 있어 질의 하나로 충분하다.

### 다대일과 다대다 관계

예제 2-1에서 regin_id, industry_id는 평문인 "그레이터 시애틀 구역"과 "자선활동"이 아니라 ID로 주어졌다.
자유 텍스트 필드가 있다면 평문으로 저장하는 편이 합리적이지만
지리적 지역과 업계의 표준 목록으로 드롭다운 리스트나 자동 완성 기능을 만들어 사용자가 선택하게 하는 데는 다음과 같은 장점이 있다.

- 프로필 간 일관된 스타일과 철자
- 모호함 회피(예를 들어 이름이 같은 여러 도시가 있는 경우)
- 갱신의 편의성. 이름이 한 곳에만 저장되므로 이름을 변경해야 하는 경우 전반적으로 갱신하기 쉽다.
- 현지화 지원. 사이트를 다른 언어로 번역할 때 표준 목록을 현지화해 지역과 업계를 사이트를 보는 사람의
언어로 표시할 수 있다.
- 더 나은 검색. 예를 들어 워싱턴 주에 있는 자선가를 검색하려 할 때 지역 목록에 시애틀이 워싱턴에 있다는 사실을
부호화("그레이터 시애틀 구역" 문자열로는 "워싱턴"을 식별하지 못함) 할 수 있기 때문에 원하는 프로필을 찾을 수 있다.

중복된 데이터를 정규화하려면 다대일(many-to-one) 관계가 필요하다.
다대일: 많은 사람들은 한 특정 지역에 살고 많은 사람들은 한 특정 업계에서 일한다.
관계형 데이터베이스에서는 조인이 쉽기 때문에 ID로 다른 테이블의 로우를 참조하는 방식은 일반적이다.
하지만 문서 데이터베이스에서는 일대다 트리 구조를 위해 조인이 필요하지 않지만 조인에 대한 지원이 보통 약하다.

- 지역명과 산업명을 예시로, 사용자 문서에 문자열로 직접 저장할 수도 있고 ID 참조 방식으로 구현할 수도 있음.
- ID 참조 방식은 일관성 유지, 수정 용이성, 중복 제거, 다국어 지원 등의 장점 존재.
- 하지만 문서 모델에서는 이러한 참조를 직접 수행하거나 애플리케이션 레벨에서 처리해야 하므로 복잡성 증가.


### 문서 데이터베이스는 역사를 반복하고 있나?

#### 네트워크 모델

- 1960~70년대의 IMS 시스템과 CODASYL 모델은 데이터를 중첩된 트리 형태로 저장했으며, 포인터 기반의 명시적 탐색 경로가 필요했음.
- 다대다 관계를 표현하기 어렵고, 경로를 바꾸면 전체 코드 수정이 필요했기 때문에 유연하지 못했음.

#### 관계형 모델

- 관계형 모델은 테이블 기반으로 데이터를 납작하게(flat) 표현하며, 쿼리 최적화기를 통해 다양한 질의가 가능하게 설계됨.
- 접근 경로를 명시할 필요 없이 자유롭게 데이터를 참조할 수 있음.
- 쿼리 최적화기 하나만 잘 만들면 여러 응용이 이를 활용 가능하다는 점에서 큰 장점이 있음.

### 문서 데이터베이스와의 비교

- 문서 모델은 1:N 트리 구조에 유리하고, 전체 문서를 한 번에 읽는 데 최적화되어 있음.
- 다대다 관계는 문서 모델에서 비효율적이며, 중복 저장, 데이터 불일치 위험, 애플리케이션 로직 복잡화가 발생함.
- 참조 ID로 관계를 표현할 경우, 문서 간 조인 지원이 부족해 별도 쿼리 또는 코드에서 처리해야 함.

### 관계형 데이터베이스와 오늘날의 문서 데이터베이스

#### 어떤 데이터 모델이 애플리케이션 코드를 더 간단하게 할까?

- 트리 구조로 데이터가 구성되어 있고 한 번에 로딩되는 경우 → 문서 모델이 단순하고 효과적.
- 문서를 잘게 나누어 여러 테이블로 저장하고 조인하는 관계형 모델은 유지보수 비용이 증가할 수 있음.
- 다대다 관계가 존재하거나, 동일한 개체를 참조하는 경우 → 관계형 모델이 더 적합.

#### 문서 모델에서의 스키마 유연성

- 문서 DB는 스키마를 강제하지 않음 → 스키마 온 리드(schema-on-read)
- 명시적 스키마가 없더라도 대부분의 코드에서 암묵적으로 구조를 가정하므로, 실질적 구조는 존재함
- 유연성은 높지만, 일관성 검사나 데이터 검증은 애플리케이션 수준에서 처리해야 함

#### 질의를 위한 데이터 지역성

- 문서는 JSON 또는 바이너리로 연속 저장됨 → 전체 문서 접근 시 빠름
- 반면 문서 크기가 클 경우, 부분만 접근하더라도 전체 문서를 로드해야 해 비효율적
- 문서의 크기를 작게 유지해야 성능상 이점이 있음

#### 문서 데이터베이스와 관계형 데이터베이스의 통합

- PostgreSQL, MySQL, DB2 등은 JSON, XML 데이터 타입과 쿼리 기능을 지원함
- MongoDB 등은 일부 조인 기능(예: `lookup`)을 도입함
- 양쪽 모두 서로의 장점을 받아들이는 형태로 진화 중 → 하이브리드 모델 가능성 확대


## 데이터를 위한 질의 언어

> 이 절에서는 데이터를 질의하는 다양한 방식, 특히 선언형 언어와 명령형 언어의 차이, 그리고 MapReduce 방식의 질의 처리 방식에 대해 설명합니다.

---

### 웹에서의 선언형 질의

- **SQL**은 대표적인 **선언형(Declarative) 질의 언어**입니다.
  - 사용자는 “무엇을 원하는지”만 명시합니다.
  - “어떻게 얻을 것인지”는 데이터베이스 쿼리 최적화기가 결정합니다.
- 이는 **CSS, XPath, XSL** 등 웹 기술의 선언형 스타일과 유사합니다.

#### 예시: CSS vs JavaScript
- 선언형(CSS):

```css
li.selected > p {
  background-color: blue;
}
```

- 명령형(JavaScript):

```javascript
var liElements = document.getElementsByTagName("li");
for (var i = 0; i < liElements.length; i++) {
    if (liElements[i].className === "selected") {
        var children = liElements[i].childNodes;
        for (var j = 0; j < children.length; j++) {
            var child = children[j];
            if (child.nodeType === Node.ELEMENT_NODE && child.tagName === "P") {
                child.setAttribute("style", "background-color: blue");
            }
        }
    }
}
```

- 선언형 스타일은 간결하며, 구조적 변화에도 자동 적용되어 유지보수가 쉬움.
- **선언형 언어의 이점**:
  - 최적화기 활용 → 성능 향상
  - 병렬 처리에 유리 → 다중 CPU 코어 활용 가능
  - 데이터의 저장 방식이나 순서에 구애받지 않음

---

### 맵리듀스 질의

- **MapReduce**는 Google이 제안한 대규모 분산 데이터 처리 모델입니다.
- MongoDB, CouchDB 등의 NoSQL 시스템은 제한된 형태의 MapReduce 기능을 제공함.

#### 기본 개념

- `map`: 문서 하나하나를 처리하여 `(key, value)` 쌍을 생성
- `reduce`: 같은 key를 가진 value들을 집계

#### 예시 (MongoDB):

```javascript
db.observations.mapReduce(
    function map() {
        var year  = this.observationTimestamp.getFullYear();
        var month = this.observationTimestamp.getMonth() + 1;
        emit(year + "-" + month, this.numAnimals);
    },
    function reduce(key, values) {
        return Array.sum(values);
    },
    {
        query: { family: "Sharks" },
        out: "monthlySharkReport"
    }
);
```

- 관찰된 상어의 수를 월별로 집계하는 예시
- `map()` 함수에서 key는 `"1995-12"` 형식, value는 `numAnimals`
- `reduce()`는 같은 달의 value들을 합산

#### 특징 및 한계

- **순수 함수** 요구: 외부 상태에 의존하지 않아야 함 → 병렬 처리 가능
- 쿼리 최적화 어려움 → SQL보다 사용자 코드 의존도가 높음
- MongoDB는 이를 보완하기 위해 **Aggregation Pipeline** 도입

```javascript
db.observations.aggregate([
  { $match: { family: "Sharks" } },
  { $group: {
      _id: {
          year: { $year: "$observationTimestamp" },
          month: { $month: "$observationTimestamp" }
      },
      totalAnimals: { $sum: "$numAnimals" }
  }}
])
```

- SQL 유사한 JSON 스타일의 선언형 질의 구조

---

> 선언형 언어는 간결성과 유지보수성, 최적화 가능성에서 강점을 가지며, 
> 
> MapReduce는 고급 쿼리의 분산 처리에 유리하나, 사용 난이도와 최적화 측면에서 한계를 가짐.



## 그래프형 데이터 모델

> 그래프 데이터 모델은 복잡한 다대다 관계나 연결 중심의 데이터를 다루기에 적합한 구조로, 다양한 종류의 객체와 관계를 유연하게 표현할 수 있습니다.

---

### 속성 그래프 (Property Graph)

- 구성 요소:
  - 정점(Vertex): 개체 (예: 사람, 장소)
  - 간선(Edge): 관계 (예: 친구, 방문함)
  - 각 정점과 간선은 고유 ID, 레이블, 속성(key-value pair)을 가질 수 있음
- Neo4j, Titan 등에서 사용됨
- SQL 테이블처럼 정점/간선을 테이블로 저장 가능
- 예시:

```sql
CREATE TABLE vertices (
    vertex_id INTEGER PRIMARY KEY,
    properties JSON
);

CREATE TABLE edges (
    edge_id INTEGER PRIMARY KEY,
    tail_vertex INTEGER,
    head_vertex INTEGER,
    label TEXT,
    properties JSON
);
```

---

### 사이퍼 질의 언어 (Cypher)

- Neo4j용 선언형 쿼리 언어
- 그래프 패턴을 시각적으로 표현 (→ 방향 간선)
- 예: 미국에서 태어나 유럽에 사는 사람 찾기

```cypher
MATCH
  (person)-[:BORN_IN]->()-[:WITHIN*0..]->(us:Location {name:'United States'}),
  (person)-[:LIVES_IN]->()-[:WITHIN*0..]->(eu:Location {name:'Europe'})
RETURN person.name
```

- `[:WITHIN*0..]`: WITHIN 관계를 0번 이상 반복하여 추적

---

### SQL의 그래프 질의

- SQL:1999 이후 `WITH RECURSIVE`를 통해 재귀적 질의 가능
- Cypher와 동일한 쿼리:

```sql
WITH RECURSIVE
  in_usa(vertex_id) AS (
    SELECT vertex_id FROM vertices WHERE properties->>'name' = 'United States'
    UNION
    SELECT edges.tail_vertex FROM edges
    JOIN in_usa ON edges.head_vertex = in_usa.vertex_id
    WHERE edges.label = 'within'
  )
-- 생략
SELECT vertices.properties->>'name'
FROM vertices
JOIN born_in_usa ON ...
```

- 복잡하고 가독성 떨어짐 → Cypher에 비해 불리함

---

### 트리플 저장소와 스파클

> RDF 기반의 그래프 표현 방식으로, 시맨틱 웹 및 연결된 데이터를 위한 표준

#### 시맨틱 웹

- 웹 상의 문서 외에 **기계가 이해 가능한 데이터** 공유를 목표로 함
- RDF는 (주어, 술어, 목적어) 트리플로 정보를 표현
- 예: (Lucy, bornIn, Idaho)

#### RDF 데이터 모델

- Turtle 문법 예시:

```turtle
@prefix : <urn:example:>.
:lucy a :Person;
      :name "Lucy";
      :bornIn :idaho.
:idaho a :Location;
       :name "Idaho";
       :within :usa.
```

- URI를 통해 전 세계적으로 고유 식별자 사용

#### 스파클 질의 언어 (SPARQL)

- RDF 트리플을 질의하기 위한 W3C 표준
- Cypher와 매우 유사한 패턴 매칭 방식

```sparql
PREFIX : <urn:example:>
SELECT ?personName WHERE {
  ?person :name ?personName.
  ?person :bornIn / :within* / :name "United States".
  ?person :livesIn / :within* / :name "Europe".
}
```

---

### 초석: 데이터로그 (Datalog)

- Prolog 계열의 **논리 기반 질의 언어**
- SPARQL과 Cypher의 이론적 기반
- 예시:

```prolog
within_recursive(Location, Name) :- name(Location, Name).
within_recursive(Location, Name) :- within(Location, Via), within_recursive(Via, Name).

migrated(Name, BornIn, LivingIn) :- 
  name(Person, Name),
  born_in(Person, BornLoc),
  within_recursive(BornLoc, BornIn),
  lives_in(Person, LivingLoc),
  within_recursive(LivingLoc, LivingIn).
```

- 규칙 기반으로 재사용성과 조합성 뛰어남
- Datomic, Cascalog 등에서 사용됨

---

> 그래프 데이터 모델은 다대다 및 복잡한 관계형 데이터를 효율적으로 표현합니다. Cypher나 SPARQL처럼 패턴 기반의 선언형 질의 언어는 이러한 구조에서 뛰어난 질의 표현력을 제공합니다.
