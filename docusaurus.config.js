// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import { themes as prismThemes } from 'prism-react-renderer';
import path from 'path';
import Prism from "prismjs";
import remarkGithubAdmonitionsToDirectives from "remark-github-admonitions-to-directives";

const prsimLanguages = ['nginx', 'php', 'yaml', 'json', 'javascript', 'ini', 'bash'];
prsimLanguages.forEach((lang) => {
    require(`prismjs/components/prism-${lang}`);
});

/** @type {import('@docusaurus/types').Config} */
const config = {
    title: 'Mbin Docs',
    tagline: '',
    favicon: 'img/favicon.ico',

    // Set the production url of your site here
    url: 'https://docs.joinmbin.org',
    // Set the /<baseUrl>/ pathname under which your site is served
    // For GitHub pages deployment, it is often '/<projectName>/'
    baseUrl: '/',

    // GitHub pages deployment config.
    // If you aren't using GitHub pages, you don't need these.
    organizationName: 'mbinOrg', // Usually your GitHub org/user name.
    projectName: 'mbin', // Usually your repo name.

    onBrokenLinks: 'warn',
    onBrokenMarkdownLinks: 'throw',

    // Even if you don't use internationalization, you can use this field to set
    // useful metadata like html lang. For example, if your site is Chinese, you
    // may want to replace "en" with "zh-Hans".
    i18n: {
        defaultLocale: 'en',
        locales: ['en'],
    },

    presets: [
        [
            'classic',
            /** @type {import('@docusaurus/preset-classic').Options} */
            ({
                docs: {
                    routeBasePath: '/',
                    // Please change this to your repo.
                    // Remove this to remove the "edit this page" links.
                    editUrl: 'https://github.com/MbinOrg/mbin/tree/main/',
                    beforeDefaultRemarkPlugins: [remarkGithubAdmonitionsToDirectives]
                },
                blog: false,
                theme: {
                    customCss: './src/css/custom.css',
                },
            }),
        ],
        [
            'redocusaurus',
            /** @type {import('redocusaurus').PresetOptions} */
            {
                specs: [
                    {
                        spec: 'docs/mbin-api.json',
                        route: '/api/'
                    }
                ],
                config: path.join(__dirname, 'redocly.yaml'),
                themeOptions: {
                    primaryColor: '#9141ac',
                    primaryColorDark: '#9c9fc9',
                }
            }
        ]
    ],

    themeConfig:
        /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
        ({
            navbar: {
                title: 'Mbin Docs',
                logo: {
                    alt: 'Mbin Logo',
                    src: 'img/logo.svg',
                },
                items: [
                    {
                        href: '/',
                        label: 'Docs',
                        position: 'left',
                    },
                    {
                        href: '/api',
                        label: 'API',
                        position: 'left',
                    },
                    {
                        href: 'https://github.com/mbinOrg/mbin',
                        label: 'GitHub',
                        position: 'right',
                    },
                ],
            },
            footer: {
                style: 'dark',
                links: [
                    {
                        title: 'Links',
                        items: [
                            {
                                href: '/',
                                label: 'Docs',
                            },
                            {
                                href: '/api',
                                label: 'API',
                            }
                        ]
                    },
                    {
                        title: 'Community',
                        items: [
                            {
                                label: 'Mbin Dev Magazine',
                                href: 'https://kbin.run/m/Mdev',
                            },
                            {
                                label: 'Mbin Releases Magazine',
                                href: 'https://gehirneimer.de/m/mbinReleases',
                            },
                            {
                                label: 'Matrix Space',
                                href: 'https://matrix.to/#/#mbin:melroy.org',
                            }
                        ],
                    },
                ],
            },
            prism: {
                theme: prismThemes.github,
                darkTheme: prismThemes.dracula,
                additionalLanguages: prsimLanguages
            },
        }),
};

export default config;
