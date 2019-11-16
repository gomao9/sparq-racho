<template>
  <div>
    <b-table striped hover :items="visibleIdols" :fields="fields" responsive stacked="sm">
      <template v-slot:cell(name)="data">
        {{ data.item.name() }}
      </template>
    </b-table>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
const fetch = require('isomorphic-fetch')
const SparqlHttp = require('sparql-http-client')
SparqlHttp.fetch = fetch

class Idol {
  url!: string
  nameJa?: string
  nameKana?: string
  alternateNameJa?: string
  alternateNameKana?: string
  givenNameJa?: string
  givenNameKana?: string
  familyNameJa?: string
  familyNameKana?: string
  hobbies?: string
  favorites?: string
  bust?: number | string
  weist?: number | string
  hip?: number | string
  height?: number | string
  weight?: number | string
  age?: number | string

  public name(): string {
    if (this.nameJa)          return `${this.nameJa}(${this.nameKana})` // prettier-ignore
    if (this.alternateNameJa) return `${this.alternateNameJa}(${this.alternateNameKana})`
    if (this.givenNameJa)     return `${this.givenNameJa}(${this.givenNameKana})` // prettier-ignore
    return ''
  }

  public textForFilter(): string {
    return [
      this.nameKana,
      this.alternateNameJa,
      this.alternateNameKana,
      this.givenNameJa,
      this.givenNameKana,
      this.familyNameJa,
      this.familyNameKana,
      this.hobbies,
      this.favorites,
    ].join(' ')
  }

  constructor(init?: Partial<Idol>) {
    Object.assign(this, init)
  }
}

@Component
export default class IdolList extends Vue {
  private idols: Array<Idol> = []
  fields: Array<object> = [
    { key: 'name', label: '名前', sortable: true },
    { key: 'age', label: '年齢', sortable: true },
  ]

  @Prop()
  public keyword!: string

  public get visibleIdols(): Array<Idol> {
    return this.idols.filter((idol: Idol) => {
      return idol.name().includes(this.keyword)
    })
  }

  public created() {
    const endpoint = new SparqlHttp({
      endpointUrl: 'https://sparql.crssnky.xyz/spql/imas',
    })
    const query = `
      PREFIX im: <http://imgpedia.dcc.uchile.cl/resource/>
      PREFIX sc: <http://purl.org/science/owl/sciencecommons/>
      PREFIX schema: <http://schema.org/>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX imas: <https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#>
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>

      SELECT *
      WHERE {
        ?url rdf:type imas:Idol.
        optional { ?url schema:name ?nameJa. filter(lang(?nameJa) = 'ja') }.
        optional { ?url schema:name ?nameEn. filter(lang(?nameEn) = 'en') }.
        optional { ?url imas:nameKana ?nameKana. }.
        optional { ?url schema:givenName ?givenNameJa. filter(lang(?givenNameJa) = 'ja') }.
        optional { ?url schema:givenName ?givenNameEn. filter(lang(?givenNameEn) = 'en') }.
        optional { ?url imas:givenNameKana ?givenNameKana. }.
        optional { ?url schema:familyName ?familyNameJa. filter( lang(?familyNameJa) = 'ja') }.
        optional { ?url schema:familyName ?familyNameEn. filter( lang(?familyNameEn) = 'en') }.
        optional { ?url imas:familyNameKana ?familyNameKana }.
        optional { ?url schema:alternateName ?alternateNameJa. filter(lang(?alternateNameJa) = 'ja') }.
        optional { ?url schema:alternateName ?alternateNameEn. filter(lang(?alternateNameEn) = 'en') }.
        optional { ?url imas:alternateNameKana ?alternateNameKana. }.
        optional { ?url schema:height ?height. }.
        optional { ?url schema:weight ?weight. }.
        optional { ?url schema:bust ?bust. }.
        optional { ?url schema:weist ?weist. }.
        optional { ?url schema:hip ?hip. }.
        optional { ?url schema:gender ?gender. }.
        optional { ?url imas:BloodType ?bloodType. }.
        optional { ?url foaf:age ?age. }.
        optional { ?url schema:birthDate ?birthDate. }.
        BIND (day(?birthDate) AS ?birthDay).
        BIND (month(?birthDate)  AS ?birthMonth).
        optional {
          SELECT ?url (group_concat(distinct ?hobby ; separator = ", ") AS ?hobbies)
            WHERE { ?url imas:Hobby ?hobby .  }
          GROUP BY ?url
        }.
        optional {
          SELECT ?url (group_concat(distinct ?favorite ; separator = ", ") AS ?favorites)
            WHERE { ?url imas:Favorite ?favorite . }
          GROUP BY ?url
        }.
      } order by ?url
      `
    endpoint
      .selectQuery(query)
      .then((res: any) => res.text())
      .then((body: string) => {
        const bindings = JSON.parse(body).results.bindings
        this.idols = bindings.map((binding: any) => {
          const o = Object.fromEntries(
            Object.entries(binding).map((entry: Array<any>) => {
              const [key, val] = entry
              return [key, val['value']]
            })
          )
          return new Idol(o)
        })
      })
  }
}
</script>
