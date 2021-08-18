FROM quay.io/openshift/origin-cli:4.9.0

ARG ocpythonlibver=0.12.1

# Dependencies for openshift-restclient-python.
RUN \
  cd /tmp && \
  curl -s -L https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python /tmp/get-pip.py && \
  pip install "setuptools>=40.3.0" urllib3 chardet requests

# Install restclient from source
RUN \
  cd /tmp && \ 
  curl -s -LO https://github.com/openshift/openshift-restclient-python/archive/v${ocpythonlibver}.tar.gz && \
  tar xvzf v${ocpythonlibver}.tar.gz && \
  cd openshift-restclient-python-${ocpythonlibver} && \
  python setup.py install

COPY src/init.py /usr/local/bin

RUN chmod +x /usr/local/bin/init.py

CMD [ "/bin/sh" ]