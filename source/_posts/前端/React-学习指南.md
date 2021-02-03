---
title: React 学习指南
date: 2020-12-10 13:34:11
tags:
- React
marks:
- 未完待续:red
- HTML:blue
- 这是什么:green
- 不重要:gray
- 自定义颜色:#0277BD
---

我是在一次无意的浏览中看到了 React，虽然 React Native 作为一种跨平台框架我已经听说过了很多次了，但是近期的项目中直接使用的是 Flutter，我也就没有对 React Native 做更多的了解，甚至完全不知道还有一个 React 的前端框架。想起前端开发，我第一次深入的学习还是在 3 年前，那时候对着教程敲出了一个类似淘宝首页的东西，主要使用的是 jQuery、Ajax 及普通的 css/js/html 操作，这是一次没有使用任何框架的学习，后来随着时间渐行渐远，我也没有更多的机会去使用它，停留在我脑中的 H5 开发技能除了 js 也就什么都不剩了。

在往后来，微信小程序出来了，这个时候除了基于微信原本的框架外，听说 Vue.js 非常的流行，就开始学习使用 Vue。Vue 给我的感觉比纯手撸页面要好的多，不过又要新学模板代码和数据处理的逻辑，我就知道在不久的以后我会忘得一干二净，果不其然，现在的我就知道 Vue 是一个前端框架，除此之外啥都没有了。

在然后，就是这次点开 React，本是无意就是想看看这又是一个什么样的前端框架，肯定又是要学一堆新的数据传递及模板代码。但是我只看到了首页的几个 Demo 就被深深的吸引了，这铺面而来的熟悉，React 基于的 Element 不就是 UIKit 中的基础组件，Component 不就是我们创建的 CustomView 吗，组件的 Sate 就如同 View、VC 中的 Model 和 State，数据的传递也是熟悉的 Block，甚至于 React 中核心思想**组合**，iOS 中基于复用和解耦也是提倡多拆分子视图。

这一切太熟悉了，然后我就花了半天的时候一口气读完了 [React 官方教程](https://zh-hans.reactjs.org/docs/hello-world.html)，这其中的学习非常的流畅，感觉就是 iOS 开发中换一种语言来叙述，下面是基于教程，提列纲要及重点，已被后续复习使用。


##  安装概要

> React 是一个用于构建用户界面的 JavaScript 库

如果想要直接体验 React 可以使用 [CodePen](https://codepen.io/pen?&editors=0010) 代码在线编辑器。如果要在本地调试学习 React，这里官方给出了几种情况：

- 如果你是在学习 React 或创建一个新的单页应用，请使用 [Create React App]()。
- 如果你是在用 Node.js 构建服务端渲染的网站，试试 [Next.js](https://nextjs.org/)。
- 如果你是在构建面向内容的静态网站，试试 [Gatsby](https://www.gatsbyjs.com/)。

这里我们使用 **[Create React App](https://github.com/facebook/create-react-app)** 开始学习，这样我们可以直接创建，并在本地开启一个服务，便于我们直接调试。

```
npx create-react-app my-app
cd my-app
npm start
```

接下来打开提示的网址，就能看到初始的网站页面了。我们后续的学习就直接在 `index.js` 中编写代码就行了，页面自动刷新。

## 基础语法

### Hello World
第一件事必定是先显示一个 **Hello, world!**，语法如下:

```js
ReactDOM.render(
  <h1>Hello, world!</h1>,
  document.getElementById('root')
);
```
这样我们就在页面中渲染了一个内容为 `Hello, world!` 标题，可以看到我们在 js 文件中直接使用了 html 的标签，这中标签语法就是 JSX，JSX 本质上还是 js 语言，它可以无缝的嵌入到 js 的运算、判断、循环中去，可以直接当做参数被传入和返回。使用 JSX 只是为了让 UI 的结构层次更为清晰，既能减少 bug 还能增加速度。

### JSX

JSX 虽然不是模板语法，但同样好用，我们可以在 JSX 中 **嵌入表达式**, 示例如下，声明并使用一个 `name` 变量：

```
const name = 'Josh Perez';
const element = <h1>Hello, {name}</h1>;

ReactDOM.render(
  element,
  document.getElementById('root')
);
```


