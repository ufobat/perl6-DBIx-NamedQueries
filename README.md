# perl6-DBIx-NamedQueries
DBIx::NamedQueries module written in perl6

[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# for local tests

    docker build -t mziescha/dbix-namedqueries-test .

    docker run -it --rm -v "$(pwd)":/app -w /app mziescha/dbix-namedqueries-test prove6 -l