FROM julia:1.4.2

RUN mkdir /app
WORKDIR /app

# Julia Project Setup
COPY ./Project.toml /app
COPY ./Manifest.toml /app
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile();"

ENV PORT "8080"
# Copy application
COPY . /app

CMD ["/usr/local/julia/bin/julia", "--project=.", "main.jl"]
