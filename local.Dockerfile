FROM jupyter/datascience-notebook:python-3.8.5

ENV PATH=$PATH:/usr/local/go/bin

USER root

# Install RISE and jupyter_contrib_nbextensions
RUN pip3 install -U pip \
 && pip3 install -U RISE jupyter_contrib_nbextensions

RUN jupyter contrib nbextension install --system \
 && jupyter nbextension enable splitcell/splitcell

# Install gophernotes
WORKDIR /usr/local

RUN wget -q https://golang.org/dl/go1.15.linux-amd64.tar.gz \
 && tar xf go1.15.linux-amd64.tar.gz \
 && rm go1.15.linux-amd64.tar.gz

RUN export GO111MODULE=on \
 && go get github.com/gopherdata/gophernotes@v0.7.1

RUN mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
 && cd ~/.local/share/jupyter/kernels/gophernotes \
 && cp ~/go/pkg/mod/github.com/gopherdata/gophernotes@v0.7.1/kernel/* "." \
 && chmod +w ./kernel.json \
 && sed "s|gophernotes|/home/jovyan/go/bin/gophernotes|" < kernel.json.in > kernel.json

ARG NB_USER=jovyan
ARG NB_UID=1000
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

WORKDIR ${HOME}/app

CMD ["jupyter", "notebook", "--ip", "0.0.0.0", "--allow-root"]
