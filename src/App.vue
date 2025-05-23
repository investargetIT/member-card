<script setup>
import { ref, onMounted, nextTick, watch } from "vue";
import html2canvas from "html2canvas";
import HelloWorld from "./components/HelloWorld.vue";
// 引入本地图片
import cardBackground from "./assets/card-back.jpg";

const cardData = ref(null);
const cardImageSrc = ref("");
const renderedImage = ref("");
const errorMessage = ref("");
const currentPath = ref("");
const isRendering = ref(false);
const showMemberCard = ref(false);

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
    isRendering.value = false;
    currentPath.value = location.href;

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
      cardImageSrc.value = `data:image/png;base64,${res.data.card}`;
    } else {
      errorMessage.value = "当前已无会员卡内容";
      return;
    }

    await nextTick();
    const cardElement = document.querySelector(
      isMemberPath ? ".member-card-content" : ".card-content"
    );
    if (cardElement) {
      isRendering.value = true;
      html2canvas(cardElement, {
        scale: 3,
        useCORS: true,
        logging: false,
        backgroundColor: null,
        imageTimeout: 0,
        allowTaint: true,
        width: 350,
        imageRendering: "pixelated",
        windowWidth: 350,
      })
        .then((canvas) => {
          renderedImage.value = canvas.toDataURL("image/png", 1.0);
          downloadImage(renderedImage.value);
          isRendering.value = false;
        })
        .catch((error) => {
          console.error("Error generating image:", error);
          errorMessage.value = "图片生成失败";
          isRendering.value = false;
        });
    }
  } catch (error) {
    console.error("There was a problem with the fetch operation:", error);
    errorMessage.value = "当前已无会员卡内容";
    isRendering.value = false;
  }
});

// 监听 renderedImage 的变化
watch(renderedImage, (newValue) => {
  if (newValue && currentPath.value.includes("/card/")) {
    showMemberCard.value = true;
  }
});
</script>

<template>
  <div v-if="errorMessage">
    <p>{{ errorMessage }}</p>
  </div>
  <div v-else>
    <!-- 加载状态 -->
    <div v-if="isRendering" class="loading-container">
      <div class="loading-spinner"></div>
      <p>生成图片中...</p>
    </div>
    <!-- 原有的卡片逻辑 -->
    <div
      v-else-if="!renderedImage && !currentPath.includes('/member/')"
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
    <!-- 会员卡显示逻辑 -->
    <div
      v-else-if="!renderedImage && currentPath.includes('/member/')"
      class="membership-card-container"
    >
      <div class="member-card-content">
        <span class="member-card-tip">Peidi 佩蒂</span>
        <img :src="cardImageSrc" alt="QR Code" class="member-qr-code" />
        <span class="member-card-no">No.{{ cardData?.cardNo }}</span>
      </div>
    </div>
    <!-- 渲染后的图片显示 -->
    <div v-else>
      <img
        :src="renderedImage"
        alt="Rendered Card"
        style="width: 350px; height: auto; border: 1px solid #ccc"
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
  left: 42.11%;
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

/* 加载状态样式 */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  width: 350px;
  background: #f5f5f5;
  border-radius: 8px;
  position: relative;
  overflow: hidden;
  transition: opacity 0.3s ease;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.loading-container p {
  color: #666;
  font-size: 14px;
  margin: 0;
  transition: opacity 0.3s ease;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>
