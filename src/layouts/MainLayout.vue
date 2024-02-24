<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-toolbar-title>
          Quasar App
          <router-link
            v-for="item in headerLinks"
            :key="item.link"
            :to="{ path: '' + item.link + '' }"
          >
            <q-btn
              flat
              dense
              round
              :icon="item.icon"
              :aria-label="item.label"
            />
          </router-link>
        </q-toolbar-title>

        <div>Quasar v{{ $q.version }}</div>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
const headerLinks = [
  {
    label: 'Kent911',
    icon: 'fa fa-house-fire',
    link: './kent911',
  },
];
</script>
