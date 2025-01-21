#FROM kasmweb/ubuntu-noble-desktop:1.16.1-rolling-daily
FROM --platform=linux/amd64 kasmweb/ubuntu-noble-desktop:1.16.1-rolling-daily

USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
# Root Berechtigung aktivieren
RUN apt-get update \
    && apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*
# Wallpaper
RUN wget https://assets.datamation.com/uploads/2023/06/dm-devops-tools-comparison.png -O /usr/share/backgrounds/bg_default.png
# Copy Scripts
COPY ./scripts $INST_SCRIPTS/scripts/
# Run Install Scripts
RUN bash $INST_SCRIPTS/scripts/install.sh
# Config Terminal to always start zsh
# Alle Dateien werden in kasm-user und kasm-default-profile abgelegt, damit sie auch bei persistenten Profilen funktionieren
COPY files/xfce4-terminal.xml /home/kasm-user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml
COPY files/xfce4-terminal.xml /home/kasm-default-profile/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml
RUN sudo chown 1000:0 /home/kasm-default-profile/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml
COPY files/zshrc /home/kasm-default-profile/.zshrc
COPY files/zshrc /home/kasm-user/.zshrc
COPY files/p10k.zsh /home/kasm-default-profile/.p10k.zsh
COPY files/p10k.zsh /home/kasm-user/.p10k.zsh
#RUN chmod 755 -R /home/kasm-default-profile/.oh-my-zsh
######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
#ADDTIONAL CUSTOMIZATION
RUN bash $INST_SCRIPTS/scripts/zsh-in-docker.sh -p git -p kubectl -p helm -p https://github.com/zsh-users/zsh-autosuggestions -p https://github.com/zsh-users/zsh-completions
RUN cp -R /home/kasm-user/.oh-my-zsh /home/kasm-default-profile/.oh-my-zsh
##END

USER root
RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME && chmod -R 755 $HOME

USER 1000