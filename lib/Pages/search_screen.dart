import 'package:flutter/material.dart';
import 'package:netflix/constants/colors.dart';
import 'package:netflix/constants/spaces.dart';
import 'package:netflix/data/url.dart';

import '../components/appbar/appbar_widget.dart';
import '../components/searchbar/searchbar_widget_one.dart';
import '../data/api.dart';
import '../data/models/search_model.dart';

class ScreenSearch extends StatelessWidget {
  ScreenSearch({super.key});

  final searchController = TextEditingController();
  final ValueNotifier<TextEditingController> searchNotifier =
      ValueNotifier(TextEditingController());

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    return Scaffold(
        appBar: appbarWidget(
          title: '',
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SearchBarWidget(
              deviceSize: deviceSize,
              search: searchNotifier,
            ),
          ),
        ),
        body: ValueListenableBuilder(
            valueListenable: searchNotifier,
            builder: (context, controller, _) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                height: deviceSize.height,
                child: controller.text.trim().isEmpty
                    ? _recomendationView()
                    : _searchResult(),
              );
            }));
  }

  Column _searchResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Movies & TV',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        vSpace10,
        Expanded(
          child: FutureBuilder<List<SearchModel>>(
            future: Api().getSearchResults(searchNotifier.value.text),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.transparent,
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text('No result found'),
                );
              }
              final results = snapshot.data ?? [];
              return GridView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1 / 1.5),
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                            image: NetworkImage(
                                '${Url.imageBaseUrl}${result.movie == null ? result.series?.posterImage ?? result.series!.coverImage : result.movie!.posterpath}'),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover)),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Column _recomendationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Searches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        vSpace10,
        Expanded(
          child: FutureBuilder<List<SearchModel>>(
            future: Api().getTreandingMoviesAndSeries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.transparent,
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text('Somthing went wrong'),
                );
              }
              final results = snapshot.data ?? [];
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    height: 80,
                    child: Row(
                      children: [
                        Container(
                          height: 100,
                          width: 155,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      '${Url.imageBaseUrl}${result.movie == null ? result.series?.coverImage ?? result.series!.posterImage : result.movie?.coverImage ?? result.movie!.posterpath}'),
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.cover)),
                        ),
                        space10,
                        Expanded(
                          child: Text(
                            result.movie?.title ?? result.series!.name,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: whiteCl.withOpacity(.5),
                          radius: 16,
                          child: const CircleAvatar(
                            backgroundColor: blackCl,
                            radius: 15.5,
                            child: Icon(
                              Icons.play_arrow,
                              color: whiteCl,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}
