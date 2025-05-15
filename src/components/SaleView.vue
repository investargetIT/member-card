<script setup>
import { ref, onMounted, onUnmounted, watch } from "vue";
import saleBackgroundAsset from "../assets/sale-bg.png";
import { Fireworks } from "@fireworks-js/vue";

// Real-time clock
const currentTime = ref("");
let clockIntervalId = null;
const formatDateTime = (date) => {
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  const hours = date.getHours().toString().padStart(2, "0");
  const minutes = date.getMinutes().toString().padStart(2, "0");
  const seconds = date.getSeconds().toString().padStart(2, "0");
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};
const updateCurrentTime = () => {
  currentTime.value = formatDateTime(new Date());
};

// Dynamic sale count - simplified for layout focus
// const currentSaleNumberString = ref("12345.99"); // Example starting number string, can change length
// let saleCountIntervalId = null;

const curSaleCount = ref(0);

const displayedDigits = ref([]);

const formatSaleCount = (num) => {
  // 只返回纯数字字符串，不加逗号
  return String(Math.floor(num));
};

const fetchSaleCount = async () => {
  try {
    const response = await fetch("https://api.peidigroup.cn/oms/bi/salesAll");
    const res = await response.json();
    if (res?.code === 200) {
      const total =
        res.data?.reduce((prev, cur) => {
          prev += cur.salesAmount;
          return prev;
        }, 0) || 0;
      curSaleCount.value = total;
      console.log("===curSaleCount数据==");
      console.log(curSaleCount.value);
    }
  } catch (error) {
    console.error("Error fetching sale count:", error);
  }
};

const fireworksRef = ref(null);

watch(
  curSaleCount,
  (newVal, oldVal) => {
    const str = formatSaleCount(newVal);
    const oldStr = oldVal !== undefined ? formatSaleCount(oldVal) : null;
    const newDigitsArray = [];
    for (let i = 0; i < str.length; i++) {
      const newValue = str[i];
      const oldValue = oldStr ? oldStr[i] : null;
      const keySuffix = Date.now() + Math.random();
      newDigitsArray.push({
        value: newValue,
        uniqueKey: `${newValue}-${i}-${
          newValue !== oldValue || !oldStr
            ? keySuffix
            : displayedDigits.value[i]?.uniqueKey.split("-")[2]
        }`,
      });
    }
    displayedDigits.value = newDigitsArray;
    // 触发烟花动画（首次不触发）
    if (fireworksRef.value && oldVal !== undefined) {
      fireworksRef.value.launch(3); // 可调整数量
    }
  },
  { immediate: true }
);

const containerRef = ref(null);
const showFullscreenBtn = ref(false);

const enterFullscreen = () => {
  if (containerRef.value && containerRef.value.requestFullscreen) {
    containerRef.value.requestFullscreen();
    showFullscreenBtn.value = false;
  }
};

onMounted(() => {
  fetchSaleCount();
  updateCurrentTime();
  clockIntervalId = setInterval(updateCurrentTime, 1000);
  // 可选：定时刷新接口
  setInterval(fetchSaleCount, 10000); // 每10秒刷新一次
  // 不再自动全屏，按钮控制
  showFullscreenBtn.value = true;
  // 监听全屏变更，退出全屏时重新显示按钮
  document.addEventListener("fullscreenchange", () => {
    if (!document.fullscreenElement) {
      showFullscreenBtn.value = true;
    }
  });
});

onUnmounted(() => {
  if (clockIntervalId) clearInterval(clockIntervalId);
});

// Props expected from App.vue
</script>

<template>
  <div class="sale-container" ref="containerRef">
    <button
      v-if="showFullscreenBtn"
      class="fullscreen-btn"
      @click="enterFullscreen"
    >
      点击此处，沉浸式体验
    </button>
    <img
      :src="saleBackgroundAsset"
      alt="Sale Background"
      class="sale-background"
    />
    <!-- New wrapper for currency and count -->
    <div class="amount-display-container">
      <span class="sale-currency">¥</span>
      <div class="sale-count-wrapper">
        <div
          class="digit-flipper"
          v-for="digitObj in displayedDigits"
          :key="digitObj.uniqueKey"
        >
          <span class="digit">{{ digitObj.value }}</span>
        </div>
      </div>
    </div>
    <div class="sale-time">{{ currentTime }}</div>
    <!-- 烟花特效全屏覆盖 -->
    <Fireworks
      ref="fireworksRef"
      :autoresize="true"
      style="
        position: fixed;
        left: 0;
        top: 0;
        width: 100vw;
        height: 100vh;
        pointer-events: none;
        z-index: 999;
      "
    />
  </div>
</template>

<style scoped>
.sale-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  position: relative;
  align-items: center;
  overflow: hidden;
  perspective: 1000px;
}

.sale-background {
  width: 100%;
  height: 100%;
  object-fit: cover;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1;
}

/* New container for currency and count, centered */
.amount-display-container {
  display: flex;
  align-items: center; /* Align currency and numbers along their baseline */
  justify-content: center; /* Center the flex items if container is wider than content */
  position: absolute;
  top: 45%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 2;
}

.sale-currency {
  /* Removed position: absolute, left, top, transform from here */
  color: #ccc;
  font-size: 4.5em; /* Adjusted to be slightly smaller than digits, tune as needed */
  font-weight: bold;
  margin-right: 0.15em; /* Space between currency and first digit */
  transform-style: preserve-3d;
  animation: flipIn 0.8s ease-out forwards;
  opacity: 0; /* Start hidden for animation */
  /* animation-delay: 0.1s; /* Optional: slight delay if needed */
}

.sale-count-wrapper {
  /* Removed position: absolute, left, top, transform from here */
  display: flex; /* This was already here for inner digits */
}

.digit-flipper {
  color: #ccc;
  font-size: 3em;
  font-weight: bold;
  margin: 0 0.05em; /* Spacing between digits */
  transform-style: preserve-3d;
  animation: flipIn 0.8s ease-out forwards;
  opacity: 0;
  transform: rotateX(-90deg);
}

.digit-flipper .digit {
  display: block;
  padding: 0.1em 0.2em;
  background-color: rgba(0, 0, 0, 0.1);
  border-radius: 0.1em;
}

@keyframes flipIn {
  0% {
    opacity: 0;
    transform: rotateX(-90deg) translateY(20px);
  }
  50% {
    transform: rotateX(20deg) translateY(0px);
  }
  100% {
    opacity: 1;
    transform: rotateX(0deg) translateY(0px);
  }
}

.sale-time {
  position: absolute;
  bottom: 3%;
  left: 50%;
  transform: translateX(-50%);
  color: #56565fa6; /* As per user change */
  font-size: 1.5em;
  z-index: 2;
}

.fullscreen-btn {
  position: fixed;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  z-index: 2000;
  padding: 1em 2em;
  font-size: 1.5em;
  background: rgba(0, 0, 0, 0.7);
  color: #fff;
  border: none;
  border-radius: 0.5em;
  cursor: pointer;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.2);
}
</style>
