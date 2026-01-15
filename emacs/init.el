;; -*- lexical-binding: t; -*-

;;; --- 1. 基础包管理设置 ---
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("org"   . "https://orgmode.org/elpa/")
	("elpa"  . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; 安装并配置 use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t) ; 默认确保安装所有包

;; --- 2. 界面与基础 UI 设置 ---
(setq inhibit-startup-message t)    ; 关闭启动界面
(menu-bar-mode -1)                  ; 禁用菜单栏
(tool-bar-mode -1)                  ; 禁用工具栏
(scroll-bar-mode -1)                ; 禁用滚动条
(global-display-line-numbers-mode t); 全局显示行号
(column-number-mode t)              ; 状态栏显示列号
(global-hl-line-mode t)             ; 高亮当前行
(cua-mode 1)

;; 滚动优化
(setq scroll-step 1
      scroll-conservatively 10000
      scroll-margin 3)

;; --- 3. Evil 模式及其相关增强 ---
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) ; 配合 evil-collection 使用（如有需要）
  (setq evil-esc-delay 0)
  (setq evil-select-enable-clipboard t)
  :config
  (evil-mode 1)
  ;; 绑定 ESC 退出各种提示框
  (define-key evil-normal-state-map (kbd "<escape>") 'keyboard-escape-quit))

(use-package evil-escape
  :init
  (setq-default evil-escape-key-sequence "jk")
  (setq-default evil-escape-delay 0.15)
  :config
  (evil-escape-mode 1))

(use-package evil-goggles
  :init
  (setq evil-goggles-duration 0.2)
  :config
  (evil-goggles-mode))

;; --- 4. WSL 剪贴板集成 (封装成函数以保持整洁) ---
(when (and (eq system-type 'gnu/linux)
           (string-match "microsoft" (shell-command-to-string "uname -a")))
  
  (defun my-wsl-copy-handler (text)
    (let ((process-connection-type nil))
      (let ((proc (start-process "win32yank" nil "win32yank.exe" "-i" "--crlf")))
        (process-send-string proc text)
        (process-send-eof proc))))

  (defun my-wsl-paste-handler ()
    (let ((output (shell-command-to-string "win32yank.exe -o --lf")))
      (unless (string= output "") output)))

  (setq interprogram-cut-function 'my-wsl-copy-handler)
  (setq interprogram-paste-function 'my-wsl-paste-handler)
  (setq select-enable-clipboard t))

;; --- 5. 主题与其它功能 ---
(use-package doom-themes
  :config
  (load-theme 'doom-one t))


;; --- 6. 杂项快捷键 ---
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; --- 7. 保持 init.el 干净：将 Custom 变量移至独立文件 ---
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
