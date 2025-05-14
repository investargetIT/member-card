<script setup>
import { ref, onMounted, onUnmounted, watch } from "vue";
import saleBackgroundAsset from "../assets/sale-bg.png";

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
const currentSaleNumberString = ref("12345.99"); // Example starting number string, can change length
let saleCountIntervalId = null;

const displayedDigits = ref([]);

watch(
  currentSaleNumberString,
  (newNumberString, oldNumberString) => {
    const newDigitsArray = [];
    if (newNumberString) {
      // Ensure newNumberString is not null/undefined
      for (let i = 0; i < newNumberString.length; i++) {
        const newValue = newNumberString[i];
        const oldValue = oldNumberString ? oldNumberString[i] : null;
        const keySuffix = Date.now() + Math.random();
        newDigitsArray.push({
          value: newValue,
          uniqueKey: `${newValue}-${i}-${
            newValue !== oldValue || !oldNumberString
              ? keySuffix
              : displayedDigits.value[i]?.uniqueKey.split("-")[2]
          }`,
        });
      }
    }
    displayedDigits.value = newDigitsArray;
  },
  { immediate: true }
);

onMounted(() => {
  updateCurrentTime();
  clockIntervalId = setInterval(updateCurrentTime, 1000);

  // Simulate saleCountString changing for a few digits and length
  saleCountIntervalId = setInterval(() => {
    let numStr = currentSaleNumberString.value || ""; // Ensure numStr is a string
    if (numStr.length > 0 && Math.random() < 0.7) {
      // Higher chance to change existing digit
      const randomIndex = Math.floor(Math.random() * numStr.length);
      const newDigit = Math.floor(Math.random() * 10).toString();
      currentSaleNumberString.value =
        numStr.substring(0, randomIndex) +
        newDigit +
        numStr.substring(randomIndex + 1);
    }

    if (Math.random() < 0.15) {
      // Chance to increase length
      if (numStr.length < 10) {
        // Max length 10 for demo
        currentSaleNumberString.value =
          numStr + Math.floor(Math.random() * 10).toString();
      }
    } else if (Math.random() < 0.1) {
      // Chance to decrease length
      if (numStr.length > 3) {
        // Min length 3 for demo
        currentSaleNumberString.value = numStr.slice(0, -1);
      }
    }
  }, 2000); // Change more frequently for testing
});

onUnmounted(() => {
  if (clockIntervalId) clearInterval(clockIntervalId);
  if (saleCountIntervalId) clearInterval(saleCountIntervalId);
});

// Props expected from App.vue
</script>

<template>
  <div class="sale-container">
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
  align-items: baseline; /* Align currency and numbers along their baseline */
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
</style>
