<script setup>
import { ref, onMounted, nextTick, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import html2canvas from "html2canvas";
import cardBackgroundAsset from "./assets/card-back.jpg";

const cardData = ref(null);
const cardImageSrc = ref("");
const renderedImage = ref("");
const errorMessage = ref("");
const currentPath = ref("");
const isRendering = ref(false); // 添加渲染状态
const route = useRoute();
const router = useRouter();

// Pass the imported background image as a prop
const cardBackground = ref(cardBackgroundAsset);

// 添加下载图片的函数
const downloadImage = (dataUrl, filename = "membership-card.png") => {
  const link = document.createElement("a");
  link.href = dataUrl;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const fetchDataAndRender = async () => {
  try {
    isRendering.value = false;
    currentPath.value = location.href;
    const href = location.href;
    // Previous regex logic restored
    const cardMatch = href.match(/\/card\/\?(\d+)/);
    const memberMatch = href.match(/\/member\/\?(\d+)/);
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
};

onMounted(() => {
  // console.log("route.name:", route.name);
  // console.log(route);
  // console.log(router);
  const isValidPath = route.name === "Member" || route.path === "/";
  if (isValidPath) {
    fetchDataAndRender();
  }
});

watch(
  () => route.fullPath,
  (newFullPath, oldFullPath) => {
    if (newFullPath && newFullPath !== oldFullPath) {
      // Re-fetch if it's a Card or Member route. ID will be parsed from href by regex.
      const isValidPath = route.name === "Member" || route.path === "/";
      if (isValidPath) {
        fetchDataAndRender();
      }
    }
  },
  { immediate: false }
);
</script>

<template>
  <div v-if="errorMessage">
    <p>{{ errorMessage }}</p>
  </div>
  <div v-else>
    <router-view
      v-if="!renderedImage"
      v-slot="{ Component, route: currentRoute }"
      :cardData="cardData"
      :cardImageSrc="cardImageSrc"
      :cardBackground="cardBackground"
    >
      <component
        :is="Component"
        :cardData="cardData"
        :cardImageSrc="cardImageSrc"
        :cardBackground="cardBackground"
      />
    </router-view>

    <div v-if="renderedImage">
      <img
        :src="renderedImage"
        alt="Rendered Card"
        style="width: 350px; height: auto; border: 1px solid #ccc"
      />
    </div>
  </div>
</template>

<style scoped>
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
/* Styles for .logo, .logo.vue, .card-footer, .footer-image can be removed if not used */
/* Or kept if they are general layout styles for App.vue */
</style>
