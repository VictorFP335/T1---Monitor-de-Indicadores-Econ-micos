# BCB Indicadores — App Flutter

Aplicativo Flutter para visualização de indicadores econômicos do Banco Central do Brasil.

---

## 📋 Pré-requisitos

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Conta Firebase com projeto criado
- FlutterFire CLI instalado

---

## 🔧 Setup — Passo a Passo

### 1. Clone / Extraia o projeto

```bash
cd bcb_app
flutter pub get
```

### 2. Configure o Firebase

**a) Instale o FlutterFire CLI (se ainda não tiver):**
```bash
dart pub global activate flutterfire_cli
```

**b) Configure o projeto Firebase:**
```bash
flutterfire configure
```
Siga as instruções e selecione seu projeto Firebase.  
Isso substituirá automaticamente o arquivo `lib/firebase_options.dart`.

**c) No Firebase Console, habilite:**
- Cloud Firestore (modo de produção ou teste)

### 3. Configure o Firestore — Coleção `indicadores`

No Firebase Console, crie manualmente a coleção `indicadores` com 4 documentos:

| Campo   | Tipo   | Documento 1       | Documento 2       | Documento 3         | Documento 4             |
|---------|--------|-------------------|-------------------|---------------------|-------------------------|
| `nome`  | string | Taxa SELIC        | IPCA (Inflação)   | Dólar (USD/BRL)     | Taxa de Desemprego      |
| `codigo`| number | 11                | 433               | 1                   | 24369                   |

> IDs dos documentos: gerados automaticamente pelo Firestore.

### 4. Regras do Firestore (para desenvolvimento)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Apenas para dev!
    }
  }
}
```

### 5. Execute o app

```bash
flutter run
```

---

## 🗂️ Estrutura do Projeto

```
lib/
├── main.dart                        # Entry point + Firebase init
├── app_theme.dart                   # Tema visual centralizado
├── firebase_options.dart            # Configuração Firebase (gerado pelo CLI)
├── models/
│   ├── indicador.dart               # Indicador (fromDoc)
│   ├── dado_serie.dart              # DadoSerie (fromJson)
│   └── analise_salva.dart           # AnaliseSalva (fromDoc + toMap)
├── services/
│   ├── bcb_service.dart             # API do Banco Central
│   └── firestore_service.dart       # CRUD Firestore
└── screens/
    ├── lista_indicadores_screen.dart  # Tela 1 — Lista (StreamBuilder)
    ├── consulta_screen.dart           # Tela 2 — Consulta (FutureBuilder)
    ├── analise_screen.dart            # Tela 3 — Análise + fl_chart
    └── analises_salvas_screen.dart    # Tela 4 — Salvas (StreamBuilder)
```

---

## ✅ Requisitos Técnicos Atendidos

| Requisito                            | Onde                                      |
|--------------------------------------|-------------------------------------------|
| 4 telas navegáveis                   | Lista → Consulta → Análise → Salvas       |
| StatefulWidget + setState (≥2)       | `ConsultaScreen`, `AnaliseScreen`         |
| Form + TextFormField + validação (≥2)| Consulta (datas), Salvar análise (nome)   |
| Chamadas HTTP à API BCB              | `BcbService.buscarSerie()`                |
| FutureBuilder com 3 estados          | `ConsultaScreen` (loading/erro/dados)     |
| Gráfico fl_chart com dados da API    | `AnaliseScreen` — LineChart + BarChart    |
| StreamBuilder vinculado ao Firestore | Lista (`indicadores`) + Salvas (`analises`)|
| Firestore add + delete               | `FirestoreService.salvarAnalise/deletar`  |
| Classes Dart fromJson/fromDoc (≥2)   | `DadoSerie.fromJson`, `Indicador.fromDoc`, `AnaliseSalva.fromDoc` |
| ListView.builder                     | `ConsultaScreen` (lista de valores)       |
| Navegação com passagem de objeto     | Lista → Consulta (Indicador), Consulta → Análise (dados) |

### Estatísticas calculadas (≥4)
1. **Mínimo** — menor valor do período
2. **Máximo** — maior valor do período
3. **Média** — média aritmética simples
4. **Mediana** — valor central ordenado
5. **Desvio Padrão** — dispersão dos valores
6. **Variação %** — variação do primeiro ao último valor
7. **Coeficiente de Variação** — desvio/média × 100
8. **Média Móvel** — janela configurável (7, 14 ou 30 períodos)

---

## 📡 API do Banco Central

```
GET https://api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados
    ?formato=json&dataInicial={DD/MM/AAAA}&dataFinal={DD/MM/AAAA}
```

| Indicador          | Código |
|--------------------|--------|
| Taxa SELIC         | 11     |
| IPCA (Inflação)    | 433    |
| Dólar (USD/BRL)    | 1      |
| Taxa de Desemprego | 24369  |
