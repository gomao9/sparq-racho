<template>
  <div class="home">
    <div class="container">
      <div class="row">
        <div class="col col-12"><FilterForm v-model="keyword"></FilterForm></div>
      </div>
      <div class="row">
        <div class="col col-12"><IdolList :keyword="keyword"></IdolList></div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import IdolList from '@/components/IdolList.vue'
import FilterForm from '@/components/FilterForm.vue'

@Component({
  components: {
    IdolList,
    FilterForm,
  },
})
export default class Home extends Vue {
  keyword: string = ''
}
</script>
