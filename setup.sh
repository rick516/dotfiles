
DOT_FILES=(.zshrc .vimrc .tmux.conf .bashrc .bash_profile)

for file in ${DOT_FILES[@]}
do
	ln -s $HOME/dotfiles/$file $HOME/$file
done



