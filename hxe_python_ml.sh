#!/bin/bash
#
# Enable eval with..
# %s/#eval \$cmd/eval \$cmd/g
#
# Disable eval with..
# %s/eval \$cmd/#eval \$cmd/g

echo ""
read -s -p "Enter hxeadm password: " hxeadmpw

cmd="echo The passwd is: $hxeadmpw"
echo $cmd
eval $cmd

echo ""
echo 'Verify that your /etc/hosts file contains hxehost.'
echo "Example.."
echo '192.168.124.14       hxehost'

echo ""
echo "In the VMWare console, login with.."
echo ""
echo "hxehost login: hxeadm"
echo "Password: $hxeadmpw"

echo "Get passwordless login of the hxeadm user setup."

zypper ar...

xs api https://hxehost:39030/ --skip-ssl-validation

// Stop everything but core procs
xs a | grep STARTED | grep -v hrtt-service | grep -v di-runner | grep -v di-core | grep -v deploy-service | cut -d ' ' -f 1 | while read -r line ; do echo "Stopping $line"; xs stop $line ; done

// Refresh the repo catalogs
zypper -n --gpg-auto-import-keys refresh

#as root
zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution --type pattern devel_basis

zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution tk-devel tcl-devel libffi-devel openssl-devel readline-devel sqlite3-devel ncurses-devel xz-devel zlib-devel nodejs wget npm lynx jq libzip2 libzip inotify-tools

#as hxeadm

wget http://thedrop.sap-a-team.com/files/hana_ml-1.0.3.tar.gz
wget http://thedrop.sap-a-team.com/files/XS_PYTHON00_1-70003433.ZIP
wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz

tar xzvf Python-3.6.5.tgz
md python_3_6_5
cd Python-3.6.5
./configure --prefix=/usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/ --exec-prefix=/usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/ ; make -j4 ; make altinstall

cd ../python_3_6_5/bin

ln -s easy_install-3.6 easy_install
ln -s pip3.6 pip
ln -s pydoc3.6 pydoc
ln -s python3.6 python
ln -s pyvenv-3.6 pyvenv

xs create-runtime -p /usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/

cd ../..

unzip XS_PYTHON00_1-70003433.ZIP -d sap_dependencies

git clone https://github.com/alundesap/mta_python_ml.git

. set_python_env.sh

#pip download -d vendor -r requirements.txt --find-links ../../sap_dependencies
#tar xzvf hana_ml-1.0.3.tar.gz

# for buildpack vendoring
pip download -d vendor -r requirements.txt --find-links ../../sap_dependencies --find-links ../../hana_ml-1.0.3.tar.gz hana_ml

# for local testing
pip install -r requirements.txt --find-links ../../sap_dependencies --find-links ../../hana_ml-1.0.3.tar.gz

pip install jupyter

jupyter notebook --generate-config

pip install sklearn
pip install mxnet
pip install tensorflow
pip install python-mnist
pip install boto3

# for CF stuff
# As root
wget -O cf-cli-installer_latest.rpm https://cli.run.pivotal.io/stable?release=redhat64
rpm -Uvh cf-cli-installer_latest.rpm

#as hxeadm
cf api https://api.cf.us10.hana.ondemand.com
#get latest from here.
#https://tools.hana.ondemand.com/#cloud
cf install-plugin cf-cli-mta-plugin-2.0.3-linux-x86_64.bin 


#vim setup as hxeadm
user vimrc file: "$HOME/.vimrc"
mkdir -p $HOME/.vim
touch $HOME/.vimrc
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

#Add to top of $HOME/.vimrc

set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


# in vim run this.
:PluginInstall

#Add to bottom of $HOME/.vimrc

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za
:w

Plugin 'tmhedberg/SimpylFold'

# in vim run this.
:PluginInstall

#Add to bottom of $HOME/.vimrc
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix


" au BufNewFile,BufRead *.js, *.html, *.css set tabstop=2 set softtabstop=2 set shiftwidth=2

Plugin 'vim-scripts/indentpython.vim'

au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

set encoding=utf-8

let python_highlight_all=1
syntax on

Plugin 'scrooloose/nerdtree'
"Plugin 'scrooloose/nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin'

Plugin 'tpope/vim-fugitive'

"Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}


