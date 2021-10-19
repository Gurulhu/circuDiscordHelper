FROM elixir:1.12-alpine AS builder

RUN mix local.hex --force
RUN mix local.rebar --force

ADD ./src/ /workspace/
WORKDIR /workspace

RUN mix deps.get

RUN mix compile

RUN mix release --overwrite

FROM alpine:latest AS runner

RUN apk add --no-cache openssl ncurses-libs libgcc libstdc++

COPY --from=builder /workspace/_build/dev/rel/lobotomist /opt/app

ENTRYPOINT ["/opt/app/bin/lobotomist"]
CMD ["start"]
