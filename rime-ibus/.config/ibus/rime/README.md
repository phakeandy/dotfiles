 ### 1. double_pinyin_flypy.custom.yaml — 全局启用 vmode 开关

在 xx.custom.yaml 中更改即可

   patch:
     translator/preedit_format: []

     engine/processors/@before 0: lua_processor@*vim_mode
     switches/+:
       - name: vmode
         reset: 1   # 原来是 0，改成 1 = 全局启用
