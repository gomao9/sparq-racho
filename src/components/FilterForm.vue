<template>
  <div>
    <div class="form-group">
      <label for="free-word">検索ワード</label>
      <input type="text" class="form-control" id="free-word" @input="input($event.target.value)" :value="value" />
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Emit, Vue } from 'vue-property-decorator'

@Component
export default class FilterForm extends Vue {
  @Prop()
  public value!: string

  @Emit()
  input(input: string) {}
}
</script>
