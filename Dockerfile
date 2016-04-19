FROM tomcat:8-jre7
MAINTAINER jripault

RUN find /var/lib/apt -type f -exec rm {} \+ && apt-get update
RUN apt-get install -y  \
        tofrodos \
        apt-utils \
        unzip \
        zip \
        make \
        gcc \
        perl \
        libexpat1-dev \
        libxml2-dev \
        zlib1g-dev \
        postgresql \
        libpq-dev \
        vim \
        build-essential \
        swig \
        postgis \
        imagemagick \
        libxml-libxslt-perl \
        p7zip-full \
        pngcheck \
        libhdf5-dev
RUN rm -rf /var/lib/apt/lists/*

RUN cd /tmp/ && \
    wget http://download.osgeo.org/proj/proj-4.7.0.tar.gz  && \
    tar -zvxf proj-4.7.0.tar.gz  && \
    cd proj-4.7.0  && \
    ./configure  && \
    make && \
    make install

RUN cd /tmp/ && \
    wget http://download.osgeo.org/gdal/gdal-1.9.2.tar.gz && \
    tar -zvxf gdal-1.9.2.tar.gz && \
    cd gdal-1.9.2 && \
    ./configure --with-static-proj4=/usr/local/lib --with-threads --with-libtiff=internal --with-geotiff=internal --with-jpeg=internal --with-gif=internal --with-png=internal --with-libz=internal --with-hdf5=/usr/lib/x86_64-linux-gnu/hdf5/serial/ && \
    make && \
    make install

RUN     cd /tmp/ && wget -q http://archive.apache.org/dist/xml/xerces-c/Xerces-C_2_7_0/source/xerces-c-src_2_7_0.tar.gz && tar -xzf xerces-c-src_2_7_0.tar.gz && \
        cd /tmp/xerces-c-src_2_7_0/src/xercesc && \
        export XERCESCROOT=/tmp/xerces-c-src_2_7_0 && \
        ./runConfigure -p linux -P/usr -c gcc -x g++ -m inmem -n socket -t native -r pthread && \
        make

RUN     cd /tmp/ && wget -q http://www.apache.org/dist/xerces/p/source/XML-Xerces-2.7.0-0.tar.gz && tar -xzf XML-Xerces-2.7.0-0.tar.gz && \
        export XERCES_DEVEL=1 && \
        export XERCESCROOT=/tmp/xerces-c-src_2_7_0 && \
        export XERCES_INCLUDE=/tmp/xerces-c-src_2_7_0/include && \
        export XERCES_LIB=/tmp/xerces-c-src_2_7_0/lib && \
        cd /tmp/XML-Xerces-2.7.0-0 && \
        perl Makefile.PL && \
        make && \
        make install

RUN export POSTGRES_HOME=/usr/share/postgresql/9.4/ && \
        cpan -i DBD::Pg && \
        service postgresql stop

COPY MyConfig.pm /root/.cpan/CPAN/MyConfig.pm
RUN     perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::Data::Inheritable')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Test::Harness')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Clone')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::SAX')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'UNIVERSAL::can')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'YAML::Syck')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Switch')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Mail::Sender')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Pod::Coverage')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Number::Format')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Locale::Maketext::Simple')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'List::MoreUtils')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'IO-stringy')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DateTime::Format::Strptime')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DateTime::Format::Builder')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Statistics::Descriptive')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'IO::Compress::Base')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'libwww::perl')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'MIME::Lite')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'rrdtool::perl')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::Simple')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Test::Pod')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Archive::Extract')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'postgresql91::plperl')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::Accessor')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'ExtUtils::ParseXS')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::DBI::Pg')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'HTML::Tagset')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Test::MockObject')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'TimeDate')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::DOM')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Math::Base36')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'YAML')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Module::Load')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'AJOLMA/Geo-GDAL-1.90.tar.gz')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DBIx::ContextualFetch')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::Singleton')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DBD::MySQL')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'devel')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'UNIVERSAL::moniker')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::NamespaceSupport')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'URI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'PPI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Compress::Raw')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Compress::Zip')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'MailTools')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Email::Date::Format')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Mail::Sendmail')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Log::Dispatch::FileRotate')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Devel::Symdump')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::XPathEngine')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Readonly::XS')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'JSON')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Config::IniFiles')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Module::Load::Conditional')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DateTime')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Test::Simple')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Params::Util')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Archive::Zip')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'HTML::Parser')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'MIME::Types')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::DOM::XPath')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Config::Simple')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'IPC::Cmd')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Git')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Params::Validate')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Ima::DBI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DBI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'ExtUtils::MakeMaker')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::DBI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::LibXML')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'UNIVERSAL::isa')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Date::Manip')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::RegExp')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Test::Pod::Coverage')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::XPath')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Params::Check')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::Factory::Util')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Class::Trigger')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DateTime::Format::Pg')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Term::ReadKey')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'IO::String')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Compress::Zlib')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'XML::Parser')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Log::Dispatch')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Log::Log4perl')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Readonly')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Net::OpenSSH')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'File::Copy::Link')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'LWP::UserAgent')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'DBI')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Perl::Critic')" && \
        perl -MCPAN -e "CPAN::Shell->notest('install', 'Error')"

