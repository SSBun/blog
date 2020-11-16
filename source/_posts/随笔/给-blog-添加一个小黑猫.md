---
title: 给 blog 添加一个小黑猫
date: 2020-01-15 17:58:41
tags:
- hexo-cactus
---

在看别人的博客时，发现右下角有一个可爱的小猫，感觉空荡荡的博客里面有这样一个小精灵还是很有意思的，然后就在网上也找了这样一个小黑猫放在我的博客下面。

> 感谢博主分享的小黑猫 [小黑猫下载](https://yaw.ee/2246.html), [我的小黑猫备份](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/codes/blackcat.zip)

我用的是 `Hexo` 的 `cactus` 主题，这里把文件夹放到 lib 目录下

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20200115180542.png)

然后在 `cactus` 的 `layout/_partical/layout.ejs` 文件中，在 `body` 最后添加如下代码:

```js
 <% if (theme.display_black_cat) { %>
    <script src="/lib/blackcat/l2dwidget.min.js"></script>
    <script type="text/javascript">
      var config = {
        model: {
          jsonPath: '/lib/blackcat/hijiki.model.json',
        },
        display: {
          superSample: 1,
          width: 245,
          height: 245,
          position: 'right',
          hOffset: 0,
          vOffset: 0,
        },
        mobile: {
          show: false,
          scale: 1,
          motion: false,
        },
        react: {
          opacityDefault: 1,
          opacityOnHover: 0.75
        }
      };
      L2Dwidget.init(config);
    </script>
    <% } %>
```

这里我在 `_config.yml` 里面添加了一个 `display_black_cat` 并设置为 `true`，这样方便以后开启和关闭此功能。

