# JI.CHANG — Engineering Notes

> **JUST CODE.**<br>
> Backend engineering, data systems, and AI notes by Jichang Jang.

[Visit the blog](https://jangjichang.github.io/) · [About](https://jangjichang.github.io/about/) · [Archive](https://jangjichang.github.io/posts/)

## About

분산 시스템, 데이터, 생성형 AI를 공부하고 제품으로 만들며 배운 내용을 기록하는 개인 기술 블로그입니다. 글을 빠르게 훑을 수 있는 명확한 정보 구조와 읽기에 집중할 수 있는 흑백 편집 디자인을 지향합니다.

## Sections

- **Engineering** — 백엔드, 분산 시스템, 데이터 저장소와 운영 경험
- **Reading Notes** — 엔지니어링 도서에서 배운 개념과 적용 사례
- **Essay** — 기술 밖에서 발견한 생각과 문화 기록

## Built with

- [Jekyll](https://jekyllrb.com/)
- [GitHub Pages](https://pages.github.com/)
- Liquid, Sass, Rouge
- Custom monochrome editorial theme

## Local development

Ruby와 Bundler가 설치된 환경에서 다음 명령을 실행합니다.

```bash
bundle install
make up
```

로컬 주소는 `http://127.0.0.1:4000`입니다.

```bash
# 새 글 생성
make new title="My New Post"

# 카테고리·태그 페이지 갱신
make cat
make tag

# 배포용 정적 빌드 확인
bundle exec jekyll build
```

## Project structure

```text
_posts/       Articles
_layouts/     Page layouts
_includes/    Reusable templates
_sass/        Editorial design system
_data/        Navigation and category data
assets/       Styles and static assets
scripts/      Category and tag generators
```

`master` 브랜치에 반영된 변경사항은 GitHub Pages를 통해 자동으로 배포됩니다.

## License and attribution

This project was originally based on [riggraz/no-style-please](https://github.com/riggraz/no-style-please), distributed under the MIT License. The original copyright notice and license are retained in [LICENSE.txt](LICENSE.txt).
