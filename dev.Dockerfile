# Cria uma imagem a partir da imagem oficial do Ruby 3.3.0
FROM registry.docker.com/library/ruby:3.3.0-slim

# Atualiza o instalador de pacotes do Linux e instala as dependências necessárias
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config curl libsqlite3-0

# Instala a versão 2.5.5 do Bundler
RUN gem install bundler -v 2.5.5

# Cria um diretório na imagem onde vão viver os arquidos da aplicação Rails
RUN mkdir /delivery_admin
WORKDIR /delivery_admin

# Copia todos os arquivos (atuais) da aplicação para a imagem
COPY . .

# Copia o Gemfile e o Gemfile.lock para a imagem
COPY Gemfile Gemfile.lock ./

# Instala as dependências da aplicação
RUN bundle install

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b '0.0.0.0' -p 3000"]
