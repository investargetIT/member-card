<script setup>
import { ref, onMounted, nextTick } from "vue";
import html2canvas from "html2canvas";
import HelloWorld from "./components/HelloWorld.vue";
// 引入本地图片
import cardBackground from "./assets/card-back.jpg";

const cardData = ref(null);
const cardImageSrc = ref("");
const renderedImage = ref("");
const errorMessage = ref("");
const currentPath = ref("");

// 添加下载图片的函数
const downloadImage = (dataUrl, filename = "membership-card.png") => {
  const link = document.createElement("a");
  link.href = dataUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

onMounted(async () => {
  try {
    // 设置当前路径
    currentPath.value = location.href;

    // 修改路径匹配逻辑，支持两种路径
    const cardMatch = location.href.match(/\/card\/\?(\d+)/);
    const memberMatch = location.href.match(/\/member\/\?(\d+)/);
    const number = cardMatch?.[1] || memberMatch?.[1];
    const isMemberPath = !!memberMatch;

    let commonUrl = "https://api.peidigroup.cn/pm/card/use";
    if (number) {
      commonUrl = `${commonUrl}?id=${number}`;
    }
    const response = await fetch(commonUrl);
    if (!response.ok) {
      throw new Error("Network response was not ok");
    }
    const res = await response.json();
    if (res.data?.card) {
      cardData.value = res.data;
    } else {
      errorMessage.value = "当前已无会员卡内容";
    }

    // 假设 cardData.value.card 是 Base64 编码的字符串
    cardImageSrc.value = `data:image/png;base64,${cardData.value.card}`;

    // 等待 DOM 渲染完成后将卡片转换为图像
    await nextTick();
    const cardElement = document.querySelector(
      isMemberPath ? ".member-card-content" : ".membership-card"
    );
    if (cardElement) {
      html2canvas(cardElement, {
        scale: 3, // 使用设备像素比
        useCORS: true, // 允许加载跨域图片
        logging: false, // 关闭日志
        backgroundColor: null, // 透明背景
        imageTimeout: 0, // 图片加载超时时间，0表示不限制
        allowTaint: true, // 允许跨域图片
        width: 350, // 固定宽度
        // 优化渲染质量
        imageRendering: "pixelated",
        // 使用 CSS 缩放
        windowWidth: 350,
      }).then((canvas) => {
        renderedImage.value = canvas.toDataURL("image/png", 1.0);

        // 自动下载生成的图片
        downloadImage(renderedImage.value);
      });
    }
  } catch (error) {
    console.error("There was a problem with the fetch operation:", error);
    errorMessage.value = "当前已无会员卡内容";
  }
});
</script>

<template>
  <div v-if="errorMessage">
    <p>{{ errorMessage }}</p>
  </div>
  <div v-else>
    <!-- 原有的卡片逻辑 -->
    <div
      v-if="!renderedImage && !currentPath.includes('/member/')"
      class="membership-card"
    >
      <div class="card-content">
        <span class="card-no">{{ cardData?.cardNo }}</span>
        <!-- 使用引入的图片作为背景 -->
        <img
          :src="cardBackground"
          alt="Card Background"
          class="card-background"
        />
        <img :src="cardImageSrc" alt="QR Code" class="qr-code" />
      </div>
    </div>
    <!-- 新增的会员卡逻辑 -->
    <div
      v-else-if="!renderedImage && currentPath.includes('/member/')"
      class="membership-card-container"
    >
      <div class="member-card-content">
        <span class="member-card-tip">Peidi 佩蒂</span>
        <img :src="cardImageSrc" alt="QR Code" class="member-qr-code" />
        <span class="member-card-no">卡号：No.{{ cardData?.cardNo }}</span>
      </div>
    </div>
    <!-- 渲染后的图片显示 -->
    <div v-else>
      <img
        :src="renderedImage"
        alt="Rendered Card"
        style="width: 350px; height: auto"
      />
    </div>
  </div>
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}

.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}

.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}

.membership-card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 0;
  /* 移除内边距 */
  width: 350px;
  margin: 0;
  text-align: center;
  box-sizing: border-box;
  /* 移除背景颜色 */
}

.card-content {
  position: relative;
  width: 100%;
  height: auto;
}

.card-no {
  position: absolute;
  top: 13.8%;
  left: 75.11%;
  font-weight: bold;
  color: #fff;
  font-size: 12px;
}

.card-background {
  width: 100%;
  height: auto;
  display: block;
}

.qr-code {
  width: 90px;
  /* 设置合理的宽度 */
  position: absolute;
  top: 339px;
  left: 130px;
  height: auto;
  display: block;
  margin: 0 auto;
  border-radius: 50%;
}

.card-footer {
  padding-top: 16px;
}

.footer-image {
  width: 100%;
  height: auto;
}
.membership-card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 0;
  width: 350px;
  margin: 0;
  text-align: center;
  box-sizing: border-box;
}
.card-content {
  position: relative;
  width: 100%;
  min-height: 620px;
  height: auto;
}

/* 新增会员卡样式 */
.membership-card-container {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 0;
  width: 350px;
  margin: 0;
  text-align: center;
  box-sizing: border-box;
}

.member-card-content {
  position: relative;
  width: 100%;
  min-height: 400px;
  height: auto;
}

.member-card-tip {
  position: absolute;
  top: 5.8%;
  left: 8.11%;
  font-weight: bold;
  color: #000;
  font-size: 18px;
  letter-spacing: 1px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.member-card-no {
  position: absolute;
  top: 75.8%;
  left: 36.11%;
  font-weight: bold;
  color: #000;
  font-size: 18px;
}

.member-qr-code {
  width: 200px;
  position: absolute;
  top: 77px;
  left: 73px;
  height: auto;
  display: block;
  margin: 0 auto;
  border-radius: 50%;
}
</style>
