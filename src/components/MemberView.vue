<script setup>
import { defineProps } from "vue";

// Props expected from App.vue
defineProps({
  cardData: Object,
  cardImageSrc: String,
});
</script>

<template>
  <div class="membership-card-container">
    <div class="member-card-content">
      <span class="member-card-tip">Peidi 佩蒂</span>
      <img :src="cardImageSrc" alt="QR Code" class="member-qr-code" />
      <span class="member-card-no">No.{{ cardData?.cardNo }}</span>
    </div>
  </div>
</template>

<style scoped>
.membership-card-container {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 0;
  width: 350px;
  margin: 0;
  text-align: center;
  box-sizing: border-box;
  display: block;
}

.member-card-content {
  position: relative;
  width: 100%;
  min-height: 400px; /* Or adjust as needed */
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
</style>
